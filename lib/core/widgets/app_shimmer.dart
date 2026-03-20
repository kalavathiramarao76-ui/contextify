import 'package:flutter/material.dart';

/// A shimmer loading skeleton placeholder.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Creates a circular shimmer (e.g. for avatars).
  const AppShimmer.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 999;

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: isDark
                  ? const [
                      Color(0xFF1E293B),
                      Color(0xFF334155),
                      Color(0xFF1E293B),
                    ]
                  : const [
                      Color(0xFFE2E8F0),
                      Color(0xFFF1F5F9),
                      Color(0xFFE2E8F0),
                    ],
            ),
          ),
        );
      },
    );
  }
}

/// A pre-built shimmer loading skeleton for analysis results.
class AnalysisShimmerLoading extends StatelessWidget {
  const AnalysisShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer(width: 200, height: 32),
          SizedBox(height: 16),
          AppShimmer(height: 120),
          SizedBox(height: 16),
          AppShimmer(width: 150, height: 24),
          SizedBox(height: 8),
          AppShimmer(height: 60),
          SizedBox(height: 16),
          AppShimmer(width: 180, height: 24),
          SizedBox(height: 8),
          AppShimmer(height: 80),
          SizedBox(height: 8),
          AppShimmer(height: 80),
        ],
      ),
    );
  }
}
