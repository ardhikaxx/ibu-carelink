import 'package:flutter/material.dart';

class AppSkeleton extends StatefulWidget {
  final Widget child;
  const AppSkeleton({super.key, required this.child});

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();

  /// Placeholder kotak serbaguna
  static Widget box({double? width, double? height, BorderRadius? borderRadius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }

  /// Placeholder bulat (untuk avatar / ikon)
  static Widget circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
    );
  }

  /// Skeleton untuk daftar item / kartu (Imunisasi, KPSP, Riwayat)
  static Widget listSkeleton({int itemCount = 5}) {
    return AppSkeleton(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                circle(size: 52),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(6)),
                      const SizedBox(height: 10),
                      box(width: 140, height: 13, borderRadius: BorderRadius.circular(6)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Skeleton untuk Dashboard Kehamilan / Anak
  static Widget dashboardSkeleton() {
    return AppSkeleton(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card Skeleton
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      circle(size: 48),
                      box(width: 100, height: 28, borderRadius: BorderRadius.circular(14)),
                    ],
                  ),
                  box(width: 220, height: 22, borderRadius: BorderRadius.circular(8)),
                  box(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(8)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid menu skeleton
            Row(
              children: [
                Expanded(child: box(height: 110, borderRadius: BorderRadius.circular(20))),
                const SizedBox(width: 16),
                Expanded(child: box(height: 110, borderRadius: BorderRadius.circular(20))),
              ],
            ),
            const SizedBox(height: 24),

            // Section title skeleton
            box(width: 180, height: 20, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 16),

            // List item skeleton
            box(width: double.infinity, height: 90, borderRadius: BorderRadius.circular(18)),
            const SizedBox(height: 12),
            box(width: double.infinity, height: 90, borderRadius: BorderRadius.circular(18)),
          ],
        ),
      ),
    );
  }
}

class _AppSkeletonState extends State<AppSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF1F5F9),
                const Color(0xFFCBD5E1),
                const Color(0xFFF1F5F9),
              ],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
