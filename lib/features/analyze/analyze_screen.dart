import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:contextify/core/design/app_colors.dart';
import 'package:contextify/core/design/app_spacing.dart';
import 'package:contextify/core/models/analysis.dart';
import 'package:contextify/core/providers/analysis_provider.dart';
import 'package:contextify/core/widgets/animated_score_ring.dart';
import 'package:contextify/core/widgets/app_shimmer.dart';
import 'package:contextify/core/widgets/flag_card.dart';
import 'package:contextify/core/widgets/risk_badge.dart';

/// The core analysis input and result screen.
class AnalyzeScreen extends ConsumerStatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  ConsumerState<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends ConsumerState<AnalyzeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  AnalysisType _selectedType = AnalysisType.general;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to analyze')),
      );
      return;
    }
    try {
      await ref
          .read(analysisProvider.notifier)
          .analyze(text, _selectedType);
      // Scroll to results after analysis
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    }
  }

  void _shareResult(AnalysisResult result) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contextify'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: AppSpacing.paddingAllMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'What do you need decoded?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Input area
            TextField(
              controller: _textController,
              maxLines: 8,
              minLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Paste a message, contract clause, email, medical bill...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                border: OutlineInputBorder(borderRadius: AppRadius.md),
                filled: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Character count
            Align(
              alignment: Alignment.centerRight,
              child: ListenableBuilder(
                listenable: _textController,
                builder: (context, _) {
                  return Text(
                    '${_textController.text.length} characters',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Quick-type chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TypeChip(
                    label: '\u{1F4F1} Text Message',
                    type: AnalysisType.message,
                    selected: _selectedType == AnalysisType.message,
                    onSelected: () =>
                        setState(() => _selectedType = AnalysisType.message),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _TypeChip(
                    label: '\u{1F4DC} Contract',
                    type: AnalysisType.contract,
                    selected: _selectedType == AnalysisType.contract,
                    onSelected: () =>
                        setState(() => _selectedType = AnalysisType.contract),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _TypeChip(
                    label: '\u{1F3E5} Medical Bill',
                    type: AnalysisType.medicalBill,
                    selected: _selectedType == AnalysisType.medicalBill,
                    onSelected: () => setState(
                        () => _selectedType = AnalysisType.medicalBill),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _TypeChip(
                    label: '\u{1F4E7} Email',
                    type: AnalysisType.email,
                    selected: _selectedType == AnalysisType.email,
                    onSelected: () =>
                        setState(() => _selectedType = AnalysisType.email),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _TypeChip(
                    label: '\u{1F4AC} Social Media',
                    type: AnalysisType.socialMedia,
                    selected: _selectedType == AnalysisType.socialMedia,
                    onSelected: () => setState(
                        () => _selectedType = AnalysisType.socialMedia),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Analyze button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: state.isLoading ? null : _analyze,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  state.isLoading ? 'Analyzing...' : 'Analyze',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.md,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Loading shimmer
            if (state.isLoading) const AnalysisShimmerLoading(),

            // Error state
            if (state.error != null && !state.isLoading)
              Card(
                color: AppColors.dangerLight,
                child: Padding(
                  padding: AppSpacing.paddingAllMd,
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Result area (currentResult is Analysis?)
            if (state.currentResult != null && !state.isLoading)
              _AnalysisResultView(
                result: state.currentResult!.result,
                onShare: () => _shareResult(state.currentResult!.result),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.type,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final AnalysisType type;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.teal.withValues(alpha: 0.15),
      checkmarkColor: AppColors.teal,
    );
  }
}

/// Displays the full analysis result.
class _AnalysisResultView extends StatelessWidget {
  const _AnalysisResultView({
    required this.result,
    required this.onShare,
  });

  final AnalysisResult result;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = AppColors.riskColor(result.riskLevel.name);
    final riskBgColor = AppColors.riskColorLight(result.riskLevel.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk level banner
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingAllMd,
          decoration: BoxDecoration(
            color: riskBgColor,
            borderRadius: AppRadius.md,
            border: Border.all(color: riskColor.withValues(alpha: 0.3)),
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

        // Manipulation score ring
        Center(
          child: AnimatedScoreRing(score: result.manipulationScore),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Plain English Summary
        _SectionCard(
          title: 'Plain English Summary',
          icon: Icons.translate,
          child: Text(result.summary, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Key Points
        _SectionCard(
          title: 'Key Points',
          icon: Icons.list_alt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: result.keyPoints
                .map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('\u2022 ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(point,
                              style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                )
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
          _SectionCard(
            title: 'Hidden Meanings',
            icon: Icons.visibility_off,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.hiddenMeanings
                  .map(
                    (meaning) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),

        // Tone Analysis
        _SectionCard(
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
          _SectionCard(
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
        const SizedBox(height: AppSpacing.lg),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: const Text('Share Analysis'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
