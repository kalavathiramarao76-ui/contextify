import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:contextify/core/design/app_colors.dart';
import 'package:contextify/core/design/app_spacing.dart';
import 'package:contextify/core/models/analysis.dart';
import 'package:contextify/core/providers/analysis_provider.dart';
import 'package:contextify/core/widgets/animated_score_ring.dart';
import 'package:contextify/core/widgets/app_empty_state.dart';
import 'package:contextify/core/widgets/flag_card.dart';
import 'package:contextify/core/widgets/risk_badge.dart';

/// Full analysis detail view (opened from history).
class AnalysisDetailScreen extends ConsumerWidget {
  const AnalysisDetailScreen({super.key, required this.analysisId});

  final String analysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(analysisHistoryProvider);
    final analysis = history.cast<Analysis?>().firstWhere(
          (a) => a?.id == analysisId,
          orElse: () => null,
        );

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis')),
        body: const AppEmptyState(
          emoji: '\u{1F50D}',
          title: 'Analysis not found',
          description: 'This analysis may have been deleted.',
        ),
      );
    }

    final result = analysis.result;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Detail'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              analysis.isFavorite ? Icons.star : Icons.star_outline,
              color: analysis.isFavorite ? AppColors.caution : null,
            ),
            onPressed: () =>
                ref.read(analysisProvider.notifier).toggleFavorite(analysis.id),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalysis(result),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Analysis'),
                  content: const Text(
                      'Are you sure you want to delete this analysis?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ).then((confirmed) {
                if (confirmed == true) {
                  ref.read(analysisProvider.notifier).delete(analysis.id);
                  if (context.mounted) context.pop();
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingAllMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original input text
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: AppSpacing.paddingAllMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.text_snippet,
                            size: 20, color: AppColors.teal),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Original Text',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.categoryColor(
                                    analysis.inputType.jsonValue)
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadius.full,
                          ),
                          child: Text(
                            analysis.inputType.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.categoryColor(
                                  analysis.inputType.jsonValue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(analysis.inputText, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Risk level banner
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingAllMd,
              decoration: BoxDecoration(
                color: AppColors.riskColorLight(result.riskLevel.name),
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: AppColors.riskColor(result.riskLevel.name)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RiskBadge(
                    riskLevel: result.riskLevel,
                    manipulationScore: result.manipulationScore,
                    showManipulation: true,
                    large: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Score ring
            Center(
              child: AnimatedScoreRing(score: result.manipulationScore),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Plain English Summary
            _DetailSection(
              title: 'Plain English Summary',
              icon: Icons.translate,
              child: Text(result.summary, style: theme.textTheme.bodyLarge),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Key Points
            _DetailSection(
              title: 'Key Points',
              icon: Icons.list_alt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.keyPoints
                    .map((point) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('\u2022 ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(point,
                                    style: theme.textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Red Flags
            if (result.flags.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: AppColors.danger, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Red Flags (${result.flags.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...result.flags.map((flag) => FlagCard(flag: flag)),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Hidden Meanings
            if (result.hiddenMeanings.isNotEmpty)
              _DetailSection(
                title: 'Hidden Meanings',
                icon: Icons.visibility_off,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.hiddenMeanings
                      .map((meaning) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.subdirectory_arrow_right,
                                    size: 16, color: AppColors.neutral400),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(meaning,
                                      style: theme.textTheme.bodyMedium),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),

            // Tone Analysis
            _DetailSection(
              title: 'Tone Analysis',
              icon: Icons.psychology,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: AppRadius.full,
                ),
                child: Text(
                  result.toneAnalysis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Suggested Response
            if (result.suggestedResponse != null)
              _DetailSection(
                title: 'Suggested Response',
                icon: Icons.reply,
                child: Container(
                  padding: AppSpacing.paddingAllSm,
                  decoration: BoxDecoration(
                    color: AppColors.safe.withValues(alpha: 0.05),
                    borderRadius: AppRadius.sm,
                    border: Border.all(
                        color: AppColors.safe.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    result.suggestedResponse!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _shareAnalysis(AnalysisResult result) {
    final buffer = StringBuffer()
      ..writeln('Contextify Analysis')
      ..writeln('---')
      ..writeln('Risk Level: ${result.riskLevel.label}')
      ..writeln('Manipulation Score: ${result.manipulationScore}/100')
      ..writeln()
      ..writeln('Summary: ${result.summary}')
      ..writeln()
      ..writeln('Key Points:');
    for (final point in result.keyPoints) {
      buffer.writeln('  - $point');
    }
    if (result.suggestedResponse != null) {
      buffer
        ..writeln()
        ..writeln('Suggested Response: ${result.suggestedResponse}');
    }
    Share.share(buffer.toString());
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.paddingAllMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.teal),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
