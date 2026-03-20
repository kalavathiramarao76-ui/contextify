import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:contextify/core/design/app_colors.dart';
import 'package:contextify/core/models/analysis.dart';
import 'package:contextify/core/providers/analysis_provider.dart';
import 'package:contextify/core/widgets/animated_score_ring.dart';
import 'package:contextify/core/widgets/app_shimmer.dart';
import 'package:contextify/core/widgets/flag_card.dart';

/// The core analysis input and result screen — fully polished.
class AnalyzeScreen extends ConsumerStatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  ConsumerState<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends ConsumerState<AnalyzeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  AnalysisType _selectedType = AnalysisType.general;

  // Animation for result slide-in
  late final AnimationController _resultAnimController;
  late final Animation<Offset> _resultSlideAnimation;
  late final Animation<double> _resultFadeAnimation;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOutCubic,
    ));
    _resultFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _resultAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    _resultAnimController.reset();

    try {
      await ref.read(analysisProvider.notifier).analyze(text, _selectedType);
      _resultAnimController.forward();
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _clearAndRestart() {
    HapticFeedback.lightImpact();
    _textController.clear();
    ref.read(analysisProvider.notifier).clearResult();
    _resultAnimController.reset();
    setState(() {});
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
    final colorScheme = theme.colorScheme;
    final state = ref.watch(analysisProvider);
    final hasInput = _textController.text.trim().isNotEmpty;
    final hasResult = state.currentResult != null && !state.isLoading;
    final showEmptyState = !hasResult && !state.isLoading && !hasInput;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'What needs decoding?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paste any text for instant AI analysis',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Input card
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(13),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _textController,
                      maxLines: 10,
                      minLines: 6,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Paste a contract, message, email, medical bill...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                        ),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),

                    // Character count
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 4),
                      child: ValueListenableBuilder(
                        valueListenable: _textController,
                        builder: (context, value, child) {
                          return Text(
                            '${_textController.text.length} characters',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant.withAlpha(128),
                            ),
                          );
                        },
                      ),
                    ),

                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      child: Row(
                        children: [
                          _buildChip(Icons.chat_bubble_outline, 'Message',
                              AnalysisType.message),
                          const SizedBox(width: 8),
                          _buildChip(Icons.description_outlined, 'Contract',
                              AnalysisType.contract),
                          const SizedBox(width: 8),
                          _buildChip(Icons.local_hospital_outlined,
                              'Medical Bill', AnalysisType.medicalBill),
                          const SizedBox(width: 8),
                          _buildChip(Icons.email_outlined, 'Email',
                              AnalysisType.email),
                          const SizedBox(width: 8),
                          _buildChip(Icons.forum_outlined, 'Social Media',
                              AnalysisType.socialMedia),
                          const SizedBox(width: 8),
                          _buildChip(Icons.article_outlined, 'General',
                              AnalysisType.general),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Analyze button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: (_textController.text.trim().isNotEmpty &&
                            !state.isLoading)
                        ? const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                          )
                        : null,
                    color: (_textController.text.trim().isEmpty ||
                            state.isLoading)
                        ? colorScheme.onSurface.withAlpha(31)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: (state.isLoading ||
                            _textController.text.trim().isEmpty)
                        ? null
                        : _analyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: colorScheme.onSurface.withAlpha(77),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Analyze',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Loading shimmer
              if (state.isLoading) const AnalysisShimmerLoading(),

              // Error state
              if (state.error != null && !state.isLoading)
                _buildErrorCard(state.error!, theme, colorScheme),

              // Empty state
              if (showEmptyState) _buildEmptyState(theme, colorScheme),

              // Result section
              if (hasResult)
                FadeTransition(
                  opacity: _resultFadeAnimation,
                  child: SlideTransition(
                    position: _resultSlideAnimation,
                    child: _AnalysisResultView(
                      result: state.currentResult!.result,
                      onShare: () =>
                          _shareResult(state.currentResult!.result),
                      onNewAnalysis: _clearAndRestart,
                      onSave: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Saved to history'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, AnalysisType type) {
    final isSelected = _selectedType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
      ),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = type),
      selectedColor: const Color(0xFF0D9488),
      backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(128),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF0D9488)
              : colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 64,
              color: const Color(0xFF0D9488).withAlpha(179),
            ),
            const SizedBox(height: 20),
            Text(
              'Your AI Text Decoder',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Paste any text — contracts, messages, medical bills — and get instant clarity.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
      String error, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withAlpha(51)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result view ──

class _AnalysisResultView extends StatelessWidget {
  const _AnalysisResultView({
    required this.result,
    required this.onShare,
    required this.onNewAnalysis,
    required this.onSave,
  });

  final AnalysisResult result;
  final VoidCallback onShare;
  final VoidCallback onNewAnalysis;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk banner
        _buildRiskBanner(colorScheme),
        const SizedBox(height: 16),

        // Manipulation score
        if (result.manipulationScore > 0) ...[
          _buildManipulationScore(colorScheme),
          const SizedBox(height: 16),
        ],

        // Summary card
        _buildSummaryCard(theme, colorScheme),
        const SizedBox(height: 12),

        // Red flags
        if (result.flags.isNotEmpty) ...[
          _buildRedFlagsSection(theme),
          const SizedBox(height: 12),
        ],

        // Hidden meanings
        if (result.hiddenMeanings.isNotEmpty) ...[
          _buildHiddenMeanings(theme, colorScheme),
          const SizedBox(height: 12),
        ],

        // Tone analysis
        _buildToneAnalysis(theme, colorScheme),
        const SizedBox(height: 12),

        // Suggested response
        if (result.suggestedResponse != null) ...[
          _buildSuggestedResponse(theme, colorScheme),
          const SizedBox(height: 16),
        ],

        // Action row
        _buildActionRow(theme, colorScheme),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRiskBanner(ColorScheme colorScheme) {
    final Color bgColor;
    final IconData icon;
    final String message;

    switch (result.riskLevel) {
      case RiskLevel.safe:
        bgColor = AppColors.safe;
        icon = Icons.verified_user_rounded;
        message = 'All Clear — This text appears safe';
      case RiskLevel.caution:
        bgColor = const Color(0xFFF59E0B);
        icon = Icons.warning_rounded;
        message = 'Proceed with Caution';
      case RiskLevel.warning:
        bgColor = AppColors.warning;
        icon = Icons.report_rounded;
        message = 'Warning — Issues Detected';
      case RiskLevel.danger:
        bgColor = AppColors.danger;
        icon = Icons.dangerous_rounded;
        message = 'Danger — Significant Red Flags';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManipulationScore(ColorScheme colorScheme) {
    final score = result.manipulationScore;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedScoreRing(
            score: score,
            size: 120,
            strokeWidth: 10,
          ),
          const SizedBox(height: 8),
          Text(
            'Manipulation Score',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plain English header
          Row(
            children: [
              const Icon(Icons.translate_rounded,
                  size: 20, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Text(
                'Plain English',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.summary,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),

          if (result.keyPoints.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

            // Key Points header
            Row(
              children: [
                const Icon(Icons.list_rounded,
                    size: 20, color: Color(0xFF0D9488)),
                const SizedBox(width: 8),
                Text(
                  'Key Points',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...result.keyPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7, right: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D9488),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRedFlagsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded, color: AppColors.danger, size: 22),
            const SizedBox(width: 8),
            Text(
              'Red Flags (${result.flags.length} found)',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...result.flags.map((flag) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FlagCard(flag: flag),
            )),
      ],
    );
  }

  Widget _buildHiddenMeanings(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility_rounded,
                  size: 20, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Text(
                'Between the Lines',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.hiddenMeanings.map(
            (meaning) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant.withAlpha(179)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      meaning,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToneAnalysis(ThemeData theme, ColorScheme colorScheme) {
    final tone = result.toneAnalysis.toLowerCase();
    final isNegative = tone.contains('manipulat') ||
        tone.contains('aggressive') ||
        tone.contains('threat') ||
        tone.contains('concern');
    final badgeColor = isNegative ? AppColors.danger : AppColors.safe;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Tone:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor.withAlpha(77)),
            ),
            child: Text(
              result.toneAnalysis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedResponse(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.reply_rounded,
                  size: 20, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Text(
                'Suggested Response',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.suggestedResponse!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: result.suggestedResponse!));
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(
                'Copy Response',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
                side: const BorderSide(color: Color(0xFF0D9488)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: onShare,
          icon: const Icon(Icons.share_rounded, size: 20),
          tooltip: 'Share Analysis',
          style: IconButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            side: BorderSide(color: colorScheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.outlined(
          onPressed: onSave,
          icon: const Icon(Icons.bookmark_outline_rounded, size: 20),
          tooltip: 'Save to History',
          style: IconButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            side: BorderSide(color: colorScheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: onNewAnalysis,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text(
            'New Analysis',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0D9488),
          ),
        ),
      ],
    );
  }
}
