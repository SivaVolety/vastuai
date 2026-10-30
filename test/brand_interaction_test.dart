import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vastuai/theme/vastu_theme.dart';
import 'package:vastuai/widgets/brand_components.dart';

double contrast(Color a, Color b) {
  final first = a.computeLuminance(), second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test(
      'CTA label contrast remains readable in normal, hover, and pressed states',
      () {
    for (final states in <Set<WidgetState>>[
      {},
      {WidgetState.hovered},
      {WidgetState.pressed}
    ]) {
      final style = VastuButtons.primary;
      expect(
          contrast(style.foregroundColor!.resolve(states)!,
              style.backgroundColor!.resolve(states)!),
          greaterThanOrEqualTo(4.5));
    }
    expect(contrast(VastuColors.muted, VastuColors.surface),
        greaterThanOrEqualTo(4.5));
    expect(contrast(VastuColors.muted, VastuColors.background),
        greaterThanOrEqualTo(4.5));
    expect(contrast(VastuColors.warning, VastuColors.surface),
        greaterThanOrEqualTo(4.5));
  });

  testWidgets(
      'CTA is at least 44px, stays disabled without a handler, and exposes focus treatment',
      (tester) async {
    Widget screen(VoidCallback? callback) => MaterialApp(
        theme: VastuTheme.light,
        home: Scaffold(
            body: PrimaryButton(
                label: 'Analyze Floor Plan', onPressed: callback)));
    await tester.pumpWidget(screen(null));
    final disabled = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(disabled.onPressed, isNull);
    expect(tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(44));
    var calls = 0;
    await tester.pumpWidget(screen(() => calls++));
    await tester.tap(find.text('Analyze Floor Plan'));
    expect(calls, 1);
    final enabled = tester.widget<FilledButton>(find.byType(FilledButton));
    final focusedBorder = enabled.style!.side!.resolve({WidgetState.focused})!;
    expect(focusedBorder.color, VastuColors.forest);
    expect(focusedBorder.width, greaterThanOrEqualTo(2));
  });

  testWidgets('select keyboard focus is visible and selection still works',
      (tester) async {
    String selected = 'Stable';
    await tester.pumpWidget(MaterialApp(
        theme: VastuTheme.light,
        home: Scaffold(
            body: StatefulBuilder(
                builder: (context, update) => BrandSelect<String>(
                      value: selected,
                      items: const [
                        DropdownMenuItem(
                            value: 'Stable', child: Text('Stable')),
                        DropdownMenuItem(value: 'Beta', child: Text('Beta'))
                      ],
                      onChanged: (value) => update(() => selected = value!),
                    )))));
    final dropdown = tester
        .widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
    expect(tester.getSize(find.byType(DropdownButton<String>)).height,
        greaterThanOrEqualTo(44));
    dropdown.focusNode!.requestFocus();
    await tester.pumpAndSettle();
    final decoration = tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
        .decoration! as BoxDecoration;
    expect((decoration.border! as Border).top.color, VastuColors.forest);
    expect(tester.getSize(find.byType(BrandSelect<String>)).height,
        greaterThanOrEqualTo(44));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(selected, 'Beta');
    expect(tester.takeException(), isNull);
  });
}
