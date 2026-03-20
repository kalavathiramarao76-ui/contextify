import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../models/analysis.dart';
import 'risk_badge.dart';

/// Displays a [RedFlag] with highlighted text quote, reason, severity badge,
/// flag type icon, and expandable detail section.
class FlagCard extends StatefulWidget {
  const FlagCard({super.key, required this.flag});

  final RedFlag flag;

  @override
  State<FlagCard> createState() => _FlagCardState();
}

class _FlagCardState extends State<FlagCard> {
  bool _expanded = false;

  IconData get _flagTypeIcon => switch (widget.flag.type) {
        FlagType.manipulation => Icons.psychology,
        FlagType.legalRisk => Icons.gavel,
        FlagType.hiddenCost => Icons.attach_money,
        FlagType.gaslighting => Icons.local_fire_department,
        FlagType.pressureTactic => Icons.speed,
        FlagType.misleading => Icons.visibility_off,
        FlagType.unclear => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.riskColor(widget.flag.severity.name);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md,
        side: BorderSide(color: color.withAlpha(77)),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: AppRadius.md,
        child: Padding(
          padding: AppSpacing.paddingAllMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(_flagTypeIcon, color: color, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      widget.flag.type.label,
                      style: theme.textTheme.titleSmall?.copyWith(color: color),
                    ),
                  ),
                  RiskBadge(riskLevel: widget.flag.severity),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              // Quoted text
              if (widget.flag.text.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingAllSm,
                  decoration: BoxDecoration(
                    color: color.withAlpha(13),
                    borderRadius: AppRadius.sm,
                    border: Border(left: BorderSide(color: color, width: 3)),
                  ),
                  child: Text(
                    '"${widget.flag.text}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              // Expandable reason
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    widget.flag.reason,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
