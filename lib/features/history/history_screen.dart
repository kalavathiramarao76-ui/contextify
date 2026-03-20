import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:contextify/core/design/app_colors.dart';
import 'package:contextify/core/models/analysis.dart';
import 'package:contextify/core/providers/analysis_provider.dart';
import 'package:contextify/core/utils/text_utils.dart';

/// Clean, professional analysis history screen.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  static const _filters = [
    'All',
    'Favorites',
    'Messages',
    'Contracts',
    'Medical',
    'Email',
  ];

  List<Analysis> _filterHistory(List<Analysis> history) {
    var filtered = history;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((a) => a.inputText.toLowerCase().contains(query))
          .toList();
    }

    filtered = switch (_selectedFilter) {
      'Favorites' => filtered.where((a) => a.isFavorite).toList(),
      'Messages' =>
        filtered.where((a) => a.inputType == AnalysisType.message).toList(),
      'Contracts' =>
        filtered.where((a) => a.inputType == AnalysisType.contract).toList(),
      'Medical' =>
        filtered.where((a) => a.inputType == AnalysisType.medicalBill).toList(),
      'Email' =>
        filtered.where((a) => a.inputType == AnalysisType.email).toList(),
      _ => filtered,
    };

    return filtered;
  }

  IconData _categoryIcon(AnalysisType type) {
    return switch (type) {
      AnalysisType.message => Icons.chat_bubble_outline_rounded,
      AnalysisType.contract => Icons.description_outlined,
      AnalysisType.medicalBill => Icons.local_hospital_outlined,
      AnalysisType.email => Icons.email_outlined,
      AnalysisType.socialMedia => Icons.forum_outlined,
      AnalysisType.general => Icons.article_outlined,
    };
  }

  Color _categoryColor(AnalysisType type) {
    return AppColors.categoryColor(type.jsonValue);
  }

  @override
  void initState() {
    super.initState();
    // Ensure history is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final history = ref.watch(analysisHistoryProvider);
    final filteredHistory = _filterHistory(history);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0D9488),
          onRefresh: () async {
            ref.read(analysisProvider.notifier).loadHistory();
          },
          child: CustomScrollView(
            slivers: [
              // Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'History',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    style: GoogleFonts.inter(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search analyses...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withAlpha(128),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = filter),
                          selectedColor: const Color(0xFF0D9488),
                          backgroundColor:
                              colorScheme.surfaceContainerHighest.withAlpha(128),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF0D9488)
                                  : colorScheme.outlineVariant.withAlpha(77),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Empty state or list
              if (filteredHistory.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 64,
                          color:
                              colorScheme.onSurfaceVariant.withAlpha(77),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No analyses yet',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Analyze your first text to see it here',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  sliver: SliverList.builder(
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final analysis = filteredHistory[index];
                      return _HistoryListItem(
                        analysis: analysis,
                        categoryIcon: _categoryIcon(analysis.inputType),
                        categoryColor: _categoryColor(analysis.inputType),
                        onTap: () =>
                            context.push('/analysis/${analysis.id}'),
                        onDelete: () {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(analysisProvider.notifier)
                              .delete(analysis.id);
                        },
                        onToggleFavorite: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(analysisProvider.notifier)
                              .toggleFavorite(analysis.id);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  const _HistoryListItem({
    required this.analysis,
    required this.categoryIcon,
    required this.categoryColor,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  final Analysis analysis;
  final IconData categoryIcon;
  final Color categoryColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  Color _riskBadgeColor(RiskLevel level) {
    return switch (level) {
      RiskLevel.safe => AppColors.safe,
      RiskLevel.caution => const Color(0xFFF59E0B),
      RiskLevel.warning => AppColors.warning,
      RiskLevel.danger => AppColors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskColor = _riskBadgeColor(analysis.result.riskLevel);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(analysis.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        onDismissed: (_) => onDelete(),
        child: Material(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  // Category icon circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcon,
                      size: 22,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TextUtils.truncateText(
                            analysis.inputText.replaceAll('\n', ' '),
                            maxLength: 60,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Risk badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: riskColor.withAlpha(26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                analysis.result.riskLevel.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: riskColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              TextUtils.getTimeAgo(analysis.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Favorite star
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      analysis.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 22,
                      color: analysis.isFavorite
                          ? const Color(0xFFF59E0B)
                          : colorScheme.onSurfaceVariant.withAlpha(128),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
