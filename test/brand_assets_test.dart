import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/config/brand_assets.dart';
import 'package:vastuai/main.dart';
import 'package:vastuai/theme/vastu_theme.dart';
import 'package:vastuai/widgets/vastu_logo.dart';

void main() {
  setUpAll(() async {
    final body = FontLoader('Lato')
      ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lato-Bold.ttf'));
    final display = FontLoader('DMSerifDisplay')
      ..addFont(rootBundle.load('assets/fonts/DMSerifDisplay-Regular.ttf'));
    await Future.wait([body.load(), display.load()]);
  });
  test('central brand assets are local vector outlines and bundled', () {
    expect(BrandAssets.logo, 'assets/branding/vasthuai-logo.svg');
    expect(BrandAssets.mark, 'assets/branding/vasthuai-icon.svg');
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final path in [
      BrandAssets.logo,
      BrandAssets.stackedLogo,
      BrandAssets.mark
    ]) {
      expect(pubspec, contains(path));
      final svg = File(path).readAsStringSync();
      expect(svg, contains('<title>VasthuAI</title>'));
      expect(svg, isNot(contains('<image')));
      expect(svg, isNot(contains('<text'))); // no host-font dependency
      expect(svg, contains('#183C36'));
      expect(svg, contains('#C78A3B'));
    }
  });
  test('favicon references resolve and production files have no old logo path',
      () {
    final html = File('web/index.html').readAsStringSync();
    expect(html, contains('sizes="32x32" href="favicon.png"'));
    expect(html, contains('sizes="16x16" href="icons/favicon-16.png"'));
    expect(html, contains('href="icons/vasthuai-favicon.svg"'));
    expect(File('web/icons/vasthuai-favicon.svg').readAsBytesSync(),
        File('assets/branding/vasthuai-favicon.svg').readAsBytesSync());
    for (final directory in ['lib', 'web']) {
      for (final file
          in Directory(directory).listSync(recursive: true).whereType<File>()) {
        if (RegExp(r'\.(dart|html|json|svg)$').hasMatch(file.path)) {
          expect(file.readAsStringSync(), isNot(contains('vastuai-mark.svg')),
              reason: file.path);
        }
      }
    }
  });
  test('favicon and manifest exports have real pixel sizes and brand colors',
      () {
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync()) as Map;
    expect(manifest['name'], 'VasthuAI');
    final exports = <String, int>{
      'web/favicon.png': 32,
      'web/icons/favicon-16.png': 16
    };
    for (final entry in manifest['icons'] as List) {
      exports['web/${entry['src']}'] =
          int.parse((entry['sizes'] as String).split('x').first);
    }
    for (final entry in exports.entries) {
      final decoded = img.decodePng(File(entry.key).readAsBytesSync())!;
      expect(decoded.width, entry.value);
      expect(decoded.height, entry.value);
      // An actual forest/cream/gold brand icon, not the stock blue Flutter mark.
      bool forest = false, gold = false, cream = false;
      for (final pixel in decoded) {
        forest |= pixel.r == 0x18 && pixel.g == 0x3c && pixel.b == 0x36;
        gold |= pixel.r == 0xc7 && pixel.g == 0x8a && pixel.b == 0x3b;
        cream |= pixel.r == 0xf7 && pixel.g == 0xf5 && pixel.b == 0xf0;
        if (entry.key.contains('maskable')) {
          expect(pixel.a, 255, reason: 'Maskable background must be opaque');
          final dx = pixel.x + .5 - decoded.width / 2,
              dy = pixel.y + .5 - decoded.height / 2;
          if (dx * dx + dy * dy > decoded.width * decoded.width * .16) {
            expect([pixel.r, pixel.g, pixel.b], [0x18, 0x3c, 0x36],
                reason: 'Art must remain in safe circle');
          }
        }
      }
      expect(forest, true);
      expect(gold, true);
      expect(cream, true);
    }
  });
  for (final width in [1440.0, 1024.0, 390.0, 320.0]) {
    testWidgets(
        'branded navbar fits ${width.toInt()}px with one accessible logo',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('VasthuAI'), findsOneWidget);
        final logo = find.byType(VastuLogo).first;
        final rect = tester.getRect(logo);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(width));
        expect(
            tester.getSize(find.byType(PreferredSize).first).height,
            width >= VastuLayout.desktop
                ? VastuLayout.navHeight
                : VastuLayout.mobileNavHeight);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }
}
