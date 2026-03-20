import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:contextify/core/design/app_colors.dart';
import 'package:contextify/core/providers/analysis_provider.dart';
import 'package:contextify/core/providers/auth_provider.dart';
import 'package:contextify/core/providers/theme_provider.dart';

/// Professional settings / profile screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);
    final history = ref.watch(analysisHistoryProvider);
    final authState = ref.watch(authProvider);

    // Compute stats
    final totalAnalyses = history.length;
    final totalFlags =
        history.fold<int>(0, (sum, a) => sum + a.result.flags.length);
    final textsDecoded = totalAnalyses;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // Title
            Text(
              'Profile',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Profile header card — auth-aware
            Container(
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
              child: authState.isLoggedIn
                  ? _buildLoggedInHeader(authState, colorScheme)
                  : _buildLoggedOutHeader(context, colorScheme),
            ),
            const SizedBox(height: 16),

            // Sync status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: authState.isLoggedIn
                    ? const Color(0xFF0D9488).withAlpha(20)
                    : colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: authState.isLoggedIn
                      ? const Color(0xFF0D9488).withAlpha(51)
                      : colorScheme.outlineVariant.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    authState.isLoggedIn
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_off_outlined,
                    size: 20,
                    color: authState.isLoggedIn
                        ? const Color(0xFF0D9488)
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authState.isLoggedIn
                          ? 'Analyses synced to cloud'
                          : 'Sign in to sync your analyses',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: authState.isLoggedIn
                            ? const Color(0xFF0D9488)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '$totalAnalyses',
                    label: 'Analyses',
                    color: const Color(0xFF0D9488),
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: '$totalFlags',
                    label: 'Flags Found',
                    color: AppColors.danger,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: '$textsDecoded',
                    label: 'Decoded',
                    color: AppColors.info,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Account section (logged in only)
            if (authState.isLoggedIn) ...[
              _SectionHeader(title: 'Account', colorScheme: colorScheme),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(8),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded,
                      color: AppColors.danger),
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.danger,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          'Log Out',
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        content: Text(
                          'Are you sure you want to log out?',
                          style: GoogleFonts.inter(),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Appearance section
            _SectionHeader(title: 'Appearance', colorScheme: colorScheme),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined,
                      size: 22, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Theme',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon:
                            Icon(Icons.settings_brightness_outlined, size: 18),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (modes) {
                      ref.read(themeProvider.notifier).setTheme(modes.first);
                    },
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Data section
            _SectionHeader(title: 'Data', colorScheme: colorScheme),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.download_outlined,
                        color: colorScheme.onSurfaceVariant),
                    title: Text(
                      'Export History',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant.withAlpha(128)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Export coming soon'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: colorScheme.outlineVariant.withAlpha(51),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                    title: Text(
                      'Clear All Data',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.danger,
                      ),
                    ),
                    subtitle: Text(
                      '$totalAnalyses analyses stored',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant.withAlpha(128)),
                    onTap: () {
                      if (history.isEmpty) return;
                      showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'Clear All Data',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600),
                          ),
                          content: Text(
                            'This will permanently delete all saved analyses. This action cannot be undone.',
                            style: GoogleFonts.inter(),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
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
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      ).then((confirmed) {
                        if (confirmed == true) {
                          ref
                              .read(analysisProvider.notifier)
                              .clearHistory();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('All data cleared'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      });
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // About section
            _SectionHeader(title: 'About', colorScheme: colorScheme),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded,
                        color: colorScheme.onSurfaceVariant),
                    title: Text(
                      'Version',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: colorScheme.outlineVariant.withAlpha(51),
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined,
                        color: colorScheme.onSurfaceVariant),
                    title: Text(
                      'Privacy Policy',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant.withAlpha(128)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Privacy Policy',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                          content: Text(
                            'Contextify processes text using AI. Your analyses are stored only on your device. We do not store, share, or sell your personal data.',
                            style: GoogleFonts.inter(height: 1.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          actions: [
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: colorScheme.outlineVariant.withAlpha(51),
                  ),
                  ListTile(
                    leading: Icon(Icons.star_outline_rounded,
                        color: colorScheme.onSurfaceVariant),
                    title: Text(
                      'Rate App',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant.withAlpha(128)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Thank you for your support!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: colorScheme.outlineVariant.withAlpha(51),
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined,
                        color: colorScheme.onSurfaceVariant),
                    title: Text(
                      'Send Feedback',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant.withAlpha(128)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Feedback feature coming soon'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade to Pro card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/paywall'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(31),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upgrade to Pro',
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Unlock the full power of Contextify',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(179),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Feature list
                        _proFeatureItem('Unlimited analyses'),
                        const SizedBox(height: 8),
                        _proFeatureItem('Advanced manipulation detection'),
                        const SizedBox(height: 8),
                        _proFeatureItem('Priority AI processing'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.push('/paywall'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0D9488),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'View Plans',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header when user is logged in.
  Widget _buildLoggedInHeader(AuthState authState, ColorScheme colorScheme) {
    final user = authState.user!;
    final initials = user.fullName.isNotEmpty
        ? user.fullName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join()
        : user.email[0].toUpperCase();

    return Row(
      children: [
        // Avatar
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName.isNotEmpty ? user.fullName : 'Contextify User',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.tier.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D9488),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Header when user is not logged in — shows sign in / create account buttons.
  Widget _buildLoggedOutHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(Icons.person_outlined, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sign in to sync your data',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D9488),
                  side: const BorderSide(color: Color(0xFF0D9488)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.go('/signup'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Create Account',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _proFeatureItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded,
            size: 18, color: Colors.white.withAlpha(204)),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white.withAlpha(230),
          ),
        ),
      ],
    );
  }
}

// ── Supporting widgets ──

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.colorScheme,
  });

  final String title;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.colorScheme,
  });

  final String value;
  final String label;
  final Color color;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
