import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contextify/core/design/app_colors.dart';
import 'package:contextify/core/design/app_spacing.dart';

/// Subscription / paywall screen.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contextify Pro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingAllMd,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Hero
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.teal, AppColors.tealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_open,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unlock Contextify Pro',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Decode anything with no limits',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Feature comparison
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: AppSpacing.paddingAllMd,
                child: Column(
                  children: [
                    _ComparisonRow(
                      feature: 'Analyses per month',
                      free: '5',
                      pro: 'Unlimited',
                      theme: theme,
                    ),
                    const Divider(),
                    _ComparisonRow(
                      feature: 'Basic summary',
                      free: '\u2705',
                      pro: '\u2705',
                      theme: theme,
                    ),
                    const Divider(),
                    _ComparisonRow(
                      feature: 'Manipulation detection',
                      free: '\u274C',
                      pro: '\u2705',
                      theme: theme,
                    ),
                    const Divider(),
                    _ComparisonRow(
                      feature: 'Pattern tracking',
                      free: '\u274C',
                      pro: '\u2705',
                      theme: theme,
                    ),
                    const Divider(),
                    _ComparisonRow(
                      feature: 'Suggested responses',
                      free: '\u274C',
                      pro: '\u2705',
                      theme: theme,
                    ),
                    const Divider(),
                    _ComparisonRow(
                      feature: 'Export analysis',
                      free: '\u274C',
                      pro: '\u2705',
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Pricing options
            Text(
              'Choose Your Plan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Monthly
            _PricingCard(
              title: 'Monthly',
              price: '\$9.99',
              period: '/month',
              isPopular: false,
              onTap: () => _showPurchaseSnackbar(context),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Yearly
            _PricingCard(
              title: 'Yearly',
              price: '\$79.99',
              period: '/year',
              badge: 'SAVE 33%',
              isPopular: true,
              onTap: () => _showPurchaseSnackbar(context),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Lifetime
            _PricingCard(
              title: 'Lifetime',
              price: '\$149.99',
              period: 'one-time',
              isPopular: false,
              onTap: () => _showPurchaseSnackbar(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Start Free Trial CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => _showPurchaseSnackbar(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.md,
                  ),
                ),
                child: const Text(
                  'Start 7-Day Free Trial',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Restore purchases
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restoring purchases...')),
                );
              },
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showPurchaseSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('In-app purchases are not configured yet.'),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.feature,
    required this.free,
    required this.pro,
    required this.theme,
  });

  final String feature;
  final String free;
  final String pro;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(feature, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Text(
              free,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              pro,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.teal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    required this.isPopular,
    required this.onTap,
  });

  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool isPopular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lg,
        side: isPopular
            ? const BorderSide(color: AppColors.teal, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lg,
        child: Padding(
          padding: AppSpacing.paddingAllMd,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.safe,
                              borderRadius: AppRadius.full,
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                  Text(
                    period,
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
    );
  }
}
