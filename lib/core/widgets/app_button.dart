import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';

/// Button variant styles.
enum AppButtonVariant { primary, secondary, ghost, danger }

/// Button size presets.
enum AppButtonSize { small, medium, large }

/// A styled button with variants, loading state, icon support, sizes, and haptic feedback.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final AppButtonVariant variant;
  final AppButtonSize size;

  double get _fontSize => switch (size) {
        AppButtonSize.small => 12,
        AppButtonSize.medium => 14,
        AppButtonSize.large => 16,
      };

  double get _iconSize => switch (size) {
        AppButtonSize.small => 16,
        AppButtonSize.medium => 20,
        AppButtonSize.large => 24,
      };

  double get _height => switch (size) {
        AppButtonSize.small => 36,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 56,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        AppButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        AppButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      };

  void _onTap() {
    HapticFeedback.lightImpact();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isLoading ? null : (onPressed != null ? _onTap : null);

    final content = isLoading
        ? SizedBox(
            height: _iconSize,
            width: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _iconSize),
                SizedBox(width: AppSpacing.xxs),
              ],
              Text(label, style: TextStyle(fontSize: _fontSize)),
            ],
          );

    final Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            padding: _padding,
            minimumSize: Size(0, _height),
          ),
          child: content,
        );
      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            padding: _padding,
            minimumSize: Size(0, _height),
          ),
          child: content,
        );
      case AppButtonVariant.ghost:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            padding: _padding,
            minimumSize: Size(0, _height),
          ),
          child: content,
        );
      case AppButtonVariant.danger:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            padding: _padding,
            minimumSize: Size(0, _height),
          ),
          child: content,
        );
    }

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        height: _height,
        child: button,
      );
    }
    return button;
  }
}
