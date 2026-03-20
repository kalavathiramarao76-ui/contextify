import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../models/analysis.dart';

/// A colored badge that displays the risk level with an icon and text.
///
/// Shows: "Safe" (green), "Caution" (amber), "Warning" (orange),
/// "Danger" (red). When [showManipulation] is true and the manipulation
/// score exceeds 60, shows "Manipulation Detected" (purple) instead.
class RiskBadge extends StatelessWidget {
  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.manipulationScore = 0,
    this.showManipulation = false,
    this.large = false,
  });

  final RiskLevel riskLevel;
  final int manipulationScore;
  final bool showManipulation;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final isManipulation = showManipulation && manipulationScore > 60;

    final String label;
    final Color color;
    final Color bgColor;
    final IconData icon;

    if (isManipulation) {
      label = 'Manipulation Detected';
      color = AppColors.manipulation;
      bgColor = AppColors.manipulationLight;
      icon = Icons.psychology_alt;
    } else {
      label = riskLevel.label;
      color = AppColors.riskColor(riskLevel.name);
      bgColor = AppColors.riskColorLight(riskLevel.name);
      icon = switch (riskLevel) {
        RiskLevel.safe => Icons.check_circle_outline,
        RiskLevel.caution => Icons.info_outline,
        RiskLevel.warning => Icons.warning_amber_rounded,
        RiskLevel.danger => Icons.dangerous_outlined,
      };
    }

    final fontSize = large ? 14.0 : 12.0;
    final iconSize = large ? 18.0 : 14.0;
    final hPadding = large ? AppSpacing.md : AppSpacing.xs;
    final vPadding = large ? AppSpacing.xs : AppSpacing.xxxs;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.full,
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
