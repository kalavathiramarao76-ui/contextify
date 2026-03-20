import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Custom theme extension for Contextify-specific semantic colors.
class ContextifyColors extends ThemeExtension<ContextifyColors> {
  const ContextifyColors({
    required this.dangerRed,
    required this.warningAmber,
    required this.safeGreen,
    required this.infoBlue,
    required this.manipulationPurple,
  });

  final Color dangerRed;
  final Color warningAmber;
  final Color safeGreen;
  final Color infoBlue;
  final Color manipulationPurple;

  static const light = ContextifyColors(
    dangerRed: AppColors.danger,
    warningAmber: AppColors.caution,
    safeGreen: AppColors.safe,
    infoBlue: AppColors.info,
    manipulationPurple: AppColors.manipulation,
  );

  static const dark = ContextifyColors(
    dangerRed: Color(0xFFFCA5A5),
    warningAmber: Color(0xFFFDE68A),
    safeGreen: Color(0xFF86EFAC),
    infoBlue: Color(0xFF93C5FD),
    manipulationPurple: Color(0xFFC4B5FD),
  );

  @override
  ContextifyColors copyWith({
    Color? dangerRed,
    Color? warningAmber,
    Color? safeGreen,
    Color? infoBlue,
    Color? manipulationPurple,
  }) {
    return ContextifyColors(
      dangerRed: dangerRed ?? this.dangerRed,
      warningAmber: warningAmber ?? this.warningAmber,
      safeGreen: safeGreen ?? this.safeGreen,
      infoBlue: infoBlue ?? this.infoBlue,
      manipulationPurple: manipulationPurple ?? this.manipulationPurple,
    );
  }

  @override
  ContextifyColors lerp(covariant ThemeExtension<ContextifyColors>? other, double t) {
    if (other is! ContextifyColors) return this;
    return ContextifyColors(
      dangerRed: Color.lerp(dangerRed, other.dangerRed, t)!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      safeGreen: Color.lerp(safeGreen, other.safeGreen, t)!,
      infoBlue: Color.lerp(infoBlue, other.infoBlue, t)!,
      manipulationPurple:
          Color.lerp(manipulationPurple, other.manipulationPurple, t)!,
    );
  }
}

/// Animation duration and curve constants.
abstract final class AppAnimation {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration scoreFill = Duration(milliseconds: 1200);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeOutCubic;
}

/// Contextify Material 3 theme configuration.
abstract final class AppTheme {
  static const Color _seedColor = Color(0xFF0D9488);

  // ── Shape System ──
  static final ShapeBorder cardShape = RoundedRectangleBorder(
    borderRadius: AppRadius.lg,
  );

  static final ShapeBorder chipShape = RoundedRectangleBorder(
    borderRadius: AppRadius.full,
  );

  static final ShapeBorder buttonShape = RoundedRectangleBorder(
    borderRadius: AppRadius.md,
  );

  static final ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: AppRadius.xxl,
  );

  // ── Text Theme ──
  static TextTheme _buildTextTheme(TextTheme base) {
    final headingStyle = GoogleFonts.plusJakartaSans(textStyle: base.bodyMedium);
    final bodyStyle = GoogleFonts.inter(textStyle: base.bodyMedium);

    return base.copyWith(
      displayLarge: headingStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      displayMedium: headingStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: headingStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: headingStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: headingStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: headingStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: headingStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: headingStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleSmall: headingStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: bodyStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Light Theme ──
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      cardTheme: CardThemeData(
        shape: cardShape,
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
      ),
      chipTheme: ChipThemeData(shape: chipShape as OutlinedBorder),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
        ),
      ),
      dialogTheme: DialogThemeData(shape: dialogShape),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: AppRadius.md),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        ContextifyColors.light,
      ],
    );
  }

  // ── Dark Theme ──
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        shape: cardShape,
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
      ),
      chipTheme: ChipThemeData(shape: chipShape as OutlinedBorder),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
        ),
      ),
      dialogTheme: DialogThemeData(shape: dialogShape),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: AppRadius.md),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        ContextifyColors.dark,
      ],
    );
  }

  // ── AMOLED Theme ──
  static ThemeData amoled() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    final colorScheme = baseColorScheme.copyWith(
      surface: AppColors.amoledBlack,
      surfaceContainerLowest: AppColors.amoledSurface,
      surfaceContainerLow: AppColors.amoledCard,
      surfaceContainer: AppColors.amoledCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.amoledBlack,
      textTheme: _buildTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        shape: cardShape,
        elevation: 0,
        color: AppColors.amoledCard,
      ),
      chipTheme: ChipThemeData(shape: chipShape as OutlinedBorder),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape as OutlinedBorder,
        ),
      ),
      dialogTheme: DialogThemeData(shape: dialogShape),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.amoledBlack,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.amoledCard,
        border: OutlineInputBorder(borderRadius: AppRadius.md),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        ContextifyColors.dark,
      ],
    );
  }
}
