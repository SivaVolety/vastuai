import 'package:flutter/material.dart';

abstract final class VastuColors {
  static const botanical = Color(0xFF244D3E);
  static const botanicalSaffron = Color(0xFFC78A3B);
  static const forest = Color(0xFF183C36);
  static const terracotta = Color(0xFFD97757);
  // Deeper action shades keep white CTA labels above 4.5:1 contrast.
  static const action = Color(0xFFB45C40);
  static const actionHover = Color(0xFFA9543A);
  static const actionPressed = Color(0xFF96482F);
  static const warning = Color(0xFF9A4D32);
  static const controlHover = Color(0xFFE8EEE7);
  static const controlPressed = Color(0xFFDDE7DD);
  static const controlHoverBorder = Color(0xFFA4B5A6);
  static const disabledSurface = Color(0xFFEBEEE7);
  static const disabledInk = Color(0xFF879087);
  static const stepSurface = Color(0xFFF3F2EC);
  static const warmBorder = Color(0xFFEEDDD0);
  static const background = Color(0xFFF7F5F0);
  static const ink = Color(0xFF1C2421);
  static const success = Color(0xFF358462);
  static const surface = Colors.white;
  static const muted = Color(0xFF667169);
  static const border = Color(0xFFDFE4DA);
  static const sage = Color(0xFFEDF2ED);
  static const canvas = Color(0xFFF5F6F1);
  static const peach = Color(0xFFFCF0E9);
  static const error = Color(0xFFAD453D);
}

abstract final class VastuBotanical {
  static const desktopOpacity = 0.26;
  static const tabletOpacity = 0.14;
  static const secondaryOpacity = 0.18;
  static const saffronOpacityFactor = 0.85;
}

abstract final class VastuSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const copyGap = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const section = 48.0;
  static const page = 64.0;
}

abstract final class VastuControl {
  static const target = 44.0;
  static const selectHeight = 48.0;
  static const primaryHeight = 52.0;
  static const focusWidth = 2.0;
  static const transition = Duration(milliseconds: 120);
}

abstract final class VastuRadius {
  static const control = 12.0;
  static const card = 24.0;
  static const pill = 999.0;
}

abstract final class VastuLayout {
  static const desktop = 1000.0;
  static const heroTextMax = 1000.0;
  static const contentMax = 1440.0;
  static const setupWidth = 380.0;
  static const navHeight = 80.0;
  static const mobileNavHeight = 72.0;
}

abstract final class VastuType {
  static const display = TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: 64,
    height: 1.06,
    letterSpacing: -1.3,
    color: VastuColors.ink,
  );
  static const title = TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: 28,
    height: 1.18,
    letterSpacing: -0.3,
    color: VastuColors.forest,
  );
  static const section = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: VastuColors.ink,
  );
  static const body = TextStyle(
    fontFamily: 'Lato',
    fontSize: 16,
    height: 1.6,
    color: VastuColors.ink,
  );
  static const small = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    height: 1.5,
    color: VastuColors.muted,
  );
  static const caption = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12,
    height: 1.4,
    color: VastuColors.muted,
  );
}

abstract final class VastuTheme {
  static const shadows = [
    BoxShadow(color: Color(0x06183C36), blurRadius: 30, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x03183C36), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static final light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Lato',
    scaffoldBackgroundColor: VastuColors.background,
    colorScheme: const ColorScheme.light(
      primary: VastuColors.forest,
      secondary: VastuColors.terracotta,
      surface: VastuColors.surface,
      onSurface: VastuColors.ink,
      error: VastuColors.error,
      outline: VastuColors.border,
    ),
    textTheme: const TextTheme(
      displayLarge: VastuType.display,
      headlineSmall: VastuType.title,
      titleMedium: VastuType.section,
      bodyLarge: VastuType.body,
      bodyMedium: VastuType.small,
      labelLarge: VastuType.section,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: VastuColors.background,
      foregroundColor: VastuColors.forest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dividerColor: VastuColors.border,
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      minimumSize: const Size(0, VastuControl.target),
      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VastuRadius.control)),
    ).copyWith(
      animationDuration: VastuControl.transition,
      side: WidgetStateProperty.resolveWith((states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? VastuColors.forest
                : Colors.transparent,
            width: VastuControl.focusWidth,
          )),
    )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VastuColors.surface,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: VastuSpace.lg, vertical: VastuSpace.md),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VastuRadius.control)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VastuRadius.control),
          borderSide: const BorderSide(color: VastuColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VastuRadius.control),
          borderSide: const BorderSide(color: VastuColors.forest, width: 1.5)),
    ),
    iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
      foregroundColor: VastuColors.forest,
      disabledForegroundColor: VastuColors.disabledInk,
      minimumSize: const Size.square(VastuControl.target),
      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VastuRadius.control)),
    ).copyWith(
            side: WidgetStateProperty.resolveWith((states) => BorderSide(
                  color: states.contains(WidgetState.focused)
                      ? VastuColors.forest
                      : Colors.transparent,
                  width: VastuControl.focusWidth,
                )))),
    tooltipTheme:
        const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
  );
}
