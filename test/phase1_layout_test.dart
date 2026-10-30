import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/main.dart';
import 'package:vastuai/theme/vastu_theme.dart';
import 'package:vastuai/widgets/analyzer/analysis_setup_card.dart';
import 'package:vastuai/widgets/analyzer/floor_plan_card.dart';

void main() {
  setUpAll(() async {
    final body = FontLoader('Lato')
      ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lato-Bold.ttf'));
    final display = FontLoader('DMSerifDisplay')
      ..addFont(rootBundle.load('assets/fonts/DMSerifDisplay-Regular.ttf'));
    await Future.wait([body.load(), display.load()]);
  });

  for (final width in [320.0, 390.0, 1024.0, 1280.0, 1440.0]) {
    testWidgets(
        'Phase 1 layout fits ${width.toInt()}px and keeps analyze disabled without an image',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Understand Your Space with VastuAI'), findsOneWidget);
      expect(find.text('Stable V1 — Recommended'), findsOneWidget);
      final floor = tester.getTopLeft(find.byType(FloorPlanCard));
      final setup = tester.getTopLeft(find.byType(AnalysisSetupCard));
      if (width >= VastuLayout.desktop) {
        expect(setup.dx, greaterThan(floor.dx));
        expect(setup.dy, closeTo(floor.dy, 1));
        expect(find.text('Analyze'), findsOneWidget);
      } else {
        expect(setup.dy, greaterThan(floor.dy));
        expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      }
      final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Analyze Floor Plan'));
      expect(button.onPressed, isNull);
    });
  }
  testWidgets('mobile upload preserves Camera and Gallery choices',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Upload Floor Plan'));
    await tester.tap(find.text('Upload Floor Plan'));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
