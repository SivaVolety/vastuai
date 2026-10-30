import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vastuai/widgets/botanical_background.dart';

void main() {
  for (final width in [1440.0, 1280.0, 1024.0, 390.0, 320.0]) {
    testWidgets(
        'botanical layer keeps layout and pointer input at ${width.toInt()}px',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var taps = 0;
      Widget screen(bool decorated) {
        final content = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => taps++,
          child: const SizedBox.expand(key: ValueKey('foreground')),
        );
        return MaterialApp(
            home: Scaffold(
                body: decorated
                    ? BotanicalBackground(
                        contentInset: width >= 1280 ? 64 : 32, child: content)
                    : content));
      }

      await tester.pumpWidget(screen(false));
      final before = tester.getRect(find.byKey(const ValueKey('foreground')));
      await tester.pumpWidget(screen(true));
      expect(tester.getRect(find.byKey(const ValueKey('foreground'))), before);
      expect(find.byKey(const ValueKey('botanical-decoration')),
          width >= 1000 ? findsOneWidget : findsNothing);
      if (width >= 1000) {
        expect(
            tester
                .widget<IgnorePointer>(
                    find.byKey(const ValueKey('botanical-decoration')))
                .ignoring,
            isTrue);
      }
      await tester.tapAt(Offset(width - 8, 100));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
