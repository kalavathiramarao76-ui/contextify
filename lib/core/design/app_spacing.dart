import 'package:flutter/material.dart';

/// Spacing constants, edge insets presets, gaps, and border radii.
abstract final class AppSpacing {
  // ── Spacing Scale ──
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // ── EdgeInsets Presets ──
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingAllXxl = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHorizontalSm =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl =
      EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets paddingVerticalXs =
      EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg =
      EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets paddingScreen =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets paddingCard =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets paddingListTile =
      EdgeInsets.symmetric(horizontal: md, vertical: xs);
}

/// Predefined gap SizedBoxes for vertical and horizontal spacing.
abstract final class Gap {
  // ── Vertical Gaps ──
  static const SizedBox v2 = SizedBox(height: AppSpacing.xxxs);
  static const SizedBox v4 = SizedBox(height: AppSpacing.xxs);
  static const SizedBox v8 = SizedBox(height: AppSpacing.xs);
  static const SizedBox v12 = SizedBox(height: AppSpacing.sm);
  static const SizedBox v16 = SizedBox(height: AppSpacing.md);
  static const SizedBox v20 = SizedBox(height: AppSpacing.lg);
  static const SizedBox v24 = SizedBox(height: AppSpacing.xl);
  static const SizedBox v32 = SizedBox(height: AppSpacing.xxl);
  static const SizedBox v40 = SizedBox(height: AppSpacing.xxxl);
  static const SizedBox v48 = SizedBox(height: AppSpacing.huge);
  static const SizedBox v64 = SizedBox(height: AppSpacing.massive);

  // ── Horizontal Gaps ──
  static const SizedBox h2 = SizedBox(width: AppSpacing.xxxs);
  static const SizedBox h4 = SizedBox(width: AppSpacing.xxs);
  static const SizedBox h8 = SizedBox(width: AppSpacing.xs);
  static const SizedBox h12 = SizedBox(width: AppSpacing.sm);
  static const SizedBox h16 = SizedBox(width: AppSpacing.md);
  static const SizedBox h20 = SizedBox(width: AppSpacing.lg);
  static const SizedBox h24 = SizedBox(width: AppSpacing.xl);
  static const SizedBox h32 = SizedBox(width: AppSpacing.xxl);
}

/// Border radius presets.
abstract final class AppRadius {
  static const double xsValue = 4.0;
  static const double smValue = 8.0;
  static const double mdValue = 12.0;
  static const double lgValue = 16.0;
  static const double xlValue = 20.0;
  static const double xxlValue = 24.0;
  static const double fullValue = 999.0;

  static const BorderRadius xs = BorderRadius.all(Radius.circular(xsValue));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(smValue));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(lgValue));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlValue));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(xxlValue));
  static const BorderRadius full =
      BorderRadius.all(Radius.circular(fullValue));
}
