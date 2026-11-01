import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vastuai/config/creator_profile.dart';
import 'package:vastuai/pages/about_page.dart';
import 'package:vastuai/widgets/about/creator_portrait.dart';

void main() {
  test('production LinkedIn is configured without invented contacts', () {
    expect(CreatorProfile.current.linkedIn,
        'https://www.linkedin.com/in/siva-volety-108a44263');
    expect(CreatorProfile.current.contacts.keys, ['LinkedIn', 'Website']);
  });

  testWidgets('both LinkedIn actions use the supplied centralized profile URL',
      (tester) async {
    const url = 'https://example.invalid/profile';
    final calls = <MethodCall>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      calls.add(call);
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(const MaterialApp(
        home:
            Scaffold(body: AboutPage(profile: CreatorProfile(linkedIn: url)))));
    for (final text in ['Stay in Touch', 'LinkedIn']) {
      final button = find.text(text);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }
    expect(calls.length, 2);
    for (final call in calls) {
      expect(call.arguments['url'], url);
      expect(call.arguments['useWebView'], false);
      expect(call.arguments['useSafariVC'], false);
    }
    expect(find.text('Email'), findsNothing);
    expect(find.text('GitHub'), findsNothing);
  });

  testWidgets('unconfigured LinkedIn hides its CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AboutPage(profile: CreatorProfile()))));
    expect(find.text('Stay in Touch'), findsNothing);
    expect(find.text('LinkedIn'), findsNothing);
  });

  testWidgets('production portrait loads the bundled photo without distortion',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body:
                CreatorPortrait(profile: CreatorProfile.current, size: 280))));
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName,
        'assets/images/siva_profile.png');
    expect(image.fit, BoxFit.cover);
    expect(find.text('SV'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing portrait falls back without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: CreatorPortrait(
                profile: CreatorProfile(photoAsset: 'missing-photo.png'),
                size: 200))));
    await tester.pumpAndSettle();
    final portrait = tester.widget<Semantics>(find
        .descendant(
            of: find.byType(CreatorPortrait), matching: find.byType(Semantics))
        .first);
    expect(portrait.properties.label,
        'Portrait of Siva Volety, creator of VasthuAI');
    expect(find.text('SV'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
