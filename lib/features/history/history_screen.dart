import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:contextify/core/design/app_colors.dart';
import 'package:contextify/core/design/app_spacing.dart';
import 'package:contextify/core/models/analysis.dart';
import 'package:contextify/core/providers/analysis_provider.dart';
import 'package:contextify/core/utils/text_utils.dart';
import 'package:contextify/core/widgets/app_empty_state.dart';
import 'package:contextify/core/widgets/risk_badge.dart';

/// Analysis history screen.
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
  ];

  List<Analysis> _filterHistory(List<Analysis> history) {
    var filtered = history;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((a) => a.inputText.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    filtered = switch (_selectedFilter) {
      'Favorites' => filtered.where((a) => a.isFavorite).toList(),
      'Messages' =>
        filtered.where((a) => a.inputType == AnalysisType.message).toList(),
      'Contracts' =>
        filtered.where((a) => a.inputType == AnalysisType.contract).toList(),
      'Medical' =>
        filtered.where((a) => a.inputType == AnalysisType.medicalBill).toList(),
      _ => filtered,
    };

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(analysisHistoryProvider);
    final filteredHistory = _filterHistory(history);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search analyses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: AppRadius.md),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedFilter = filter),
                    selectedColor: AppColors.teal.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.teal,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // History list
          Expanded(
            child: filteredHistory.isEmpty
                ? const AppEmptyState(
                    emoji: '\u{1F4CB}',
                    title: 'No analyses yet',
                    description:
                        'Your decoded texts will appear here. Start by analyzing something!',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final analysis = filteredHistory[index];
                      return _HistoryCard(
                        analysis: analysis,
                        onTap: () =>
                            context.push('/analysis/${analysis.id}'),
                        onDelete: () => ref
                            .read(analysisProvider.notifier)
                            .delete(analysis.id),
                        onToggleFavorite: () => ref
                            .read(analysisProvider.notifier)
                            .toggleFavorite(analysis.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.analysis,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  final Analysis analysis;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(analysis.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: AppRadius.md,
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: AppSpacing.paddingAllMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        TextUtils.truncateText(analysis.inputText,
                            maxLength: 80),
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        analysis.isFavorite
                            ? Icons.star
                            : Icons.star_outline,
                        color: analysis.isFavorite
                            ? AppColors.caution
                            : null,
                        size: 20,
                      ),
                      onPressed: onToggleFavorite,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors
                            .categoryColor(analysis.inputType.jsonValue)
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
                    const SizedBox(width: AppSpacing.xs),
                    RiskBadge(riskLevel: analysis.result.riskLevel),
                    const Spacer(),
                    Text(
                      TextUtils.getTimeAgo(analysis.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
