import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../design/app_theme.dart';

/// Card style variants.
enum AppCardVariant { elevated, filled, outlined }

/// A styled card with tap ripple and press scale animation.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.onTap,
    this.variant = AppCardVariant.filled,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final AppCardVariant variant;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimation.fast,
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) _scaleController.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double elevation;
    final Color? cardColor;
    final BorderSide borderSide;

    switch (widget.variant) {
      case AppCardVariant.elevated:
        elevation = 2;
        cardColor = widget.color ?? theme.colorScheme.surfaceContainerLow;
        borderSide = BorderSide.none;
      case AppCardVariant.filled:
        elevation = 0;
        cardColor = widget.color ?? theme.colorScheme.surfaceContainerLowest;
        borderSide = BorderSide.none;
      case AppCardVariant.outlined:
        elevation = 0;
        cardColor = widget.color ?? Colors.transparent;
        borderSide = BorderSide(
          color: widget.borderColor ?? theme.colorScheme.outlineVariant,
        );
    }

    final card = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Card(
        elevation: elevation,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lg,
          side: borderSide,
        ),
        margin: widget.margin ?? EdgeInsets.zero,
        child: widget.onTap != null
            ? InkWell(
                onTap: widget.onTap,
                borderRadius: AppRadius.lg,
                child: Padding(
                  padding: widget.padding ?? AppSpacing.paddingAllMd,
                  child: widget.child,
                ),
              )
            : Padding(
                padding: widget.padding ?? AppSpacing.paddingAllMd,
                child: widget.child,
              ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: card,
      );
    }

    return card;
  }
}
