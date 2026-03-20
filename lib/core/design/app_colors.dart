import 'package:flutter/material.dart';

/// Contextify color system for risk levels, analysis categories, and gradients.
abstract final class AppColors {
  // ── Brand ──
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF5EEAD4);
  static const Color tealDark = Color(0xFF0F766E);

  // ── Risk Level ──
  static const Color safe = Color(0xFF22C55E);
  static const Color safeLight = Color(0xFFDCFCE7);
  static const Color safeDark = Color(0xFF16A34A);

  static const Color caution = Color(0xFFFBBF24);
  static const Color cautionLight = Color(0xFFFEF9C3);
  static const Color cautionDark = Color(0xFFD97706);

  static const Color warning = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFFF7ED);
  static const Color warningDark = Color(0xFFEA580C);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color dangerDark = Color(0xFFDC2626);

  static const Color manipulation = Color(0xFF8B5CF6);
  static const Color manipulationLight = Color(0xFFEDE9FE);
  static const Color manipulationDark = Color(0xFF7C3AED);

  // ── Analysis Categories ──
  static const Color categoryMessage = Color(0xFF3B82F6);
  static const Color categoryContract = Color(0xFF6366F1);
  static const Color categoryMedicalBill = Color(0xFFEC4899);
  static const Color categoryEmail = Color(0xFF14B8A6);
  static const Color categorySocialMedia = Color(0xFFF43F5E);
  static const Color categoryGeneral = Color(0xFF64748B);

  // ── Semantic ──
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Neutral ──
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ── AMOLED ──
  static const Color amoledBlack = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0A0A);
  static const Color amoledCard = Color(0xFF121212);

  /// Returns the [Color] for a given risk level name.
  static Color riskColor(String riskLevel) {
    return switch (riskLevel.toLowerCase()) {
      'safe' => safe,
      'caution' => caution,
      'warning' => warning,
      'danger' => danger,
      'manipulation' => manipulation,
      _ => neutral400,
    };
  }

  /// Returns the light/background variant for a given risk level name.
  static Color riskColorLight(String riskLevel) {
    return switch (riskLevel.toLowerCase()) {
      'safe' => safeLight,
      'caution' => cautionLight,
      'warning' => warningLight,
      'danger' => dangerLight,
      'manipulation' => manipulationLight,
      _ => neutral100,
    };
  }

  /// Returns the category color for a given analysis type.
  static Color categoryColor(String type) {
    return switch (type.toLowerCase()) {
      'message' => categoryMessage,
      'contract' => categoryContract,
      'medical_bill' => categoryMedicalBill,
      'email' => categoryEmail,
      'social_media' => categorySocialMedia,
      _ => categoryGeneral,
    };
  }
}

/// Pre-built gradient presets.
abstract final class AppGradients {
  static const LinearGradient tealGradient = LinearGradient(
    colors: [AppColors.teal, AppColors.tealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [AppColors.danger, AppColors.warning],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient manipulationGradient = LinearGradient(
    colors: [AppColors.manipulation, AppColors.danger],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient safeGradient = LinearGradient(
    colors: [AppColors.safe, AppColors.teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scoreRingGradient = LinearGradient(
    colors: [
      AppColors.safe,
      AppColors.caution,
      AppColors.warning,
      AppColors.danger,
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const LinearGradient shimmer = LinearGradient(
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient shimmerDark = LinearGradient(
    colors: [
      Color(0xFF1E293B),
      Color(0xFF334155),
      Color(0xFF1E293B),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
