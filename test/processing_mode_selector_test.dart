import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/providers/rule_set_provider.dart';
import 'package:vastuai/widgets/processing_mode_selector.dart';

void main() {
  for (final width in [320.0, 390.0, 1280.0]) {
    testWidgets('rule selector and edit control fit at ${width.toInt()}px',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final rules = RuleSetProvider();
      await rules.load();
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: rules,
        child: MaterialApp(
          routes: {'/settings': (_) => const Text('Rule manager opened')},
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: ProcessingModeSelector(),
            ),
          ),
        ),
      ));
      for (final preset in ['Vastu Presets', 'Feng Shui Compass Preset']) {
        await rules.select(preset);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final edit = tester.getRect(find.byTooltip('Manage rule sets'));
        expect(edit.left, greaterThanOrEqualTo(16));
        expect(edit.right, lessThanOrEqualTo(width - 16));
      }
      await tester.tap(find.byTooltip('Manage rule sets'));
      await tester.pumpAndSettle();
      expect(find.text('Rule manager opened'), findsOneWidget);
    });
  }
}
