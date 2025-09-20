import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Utility class for creating consistent animations throughout the app
class AnimationUtils {
  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  
  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;

  /// Creates a fade-in animation for widgets
  static Widget fadeIn({
    required Widget child,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a slide-in animation from the specified direction
  static Widget slideIn({
    required Widget child,
    Duration duration = normalDuration,
    Curve curve = slideCurve,
    Offset begin = const Offset(0.0, 1.0),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a scale animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = normalDuration,
    Curve curve = bounceCurve,
    double begin = 0.0,
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a staggered animation for list items
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration duration = normalDuration,
    double delay = 100.0,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      delay: Duration(milliseconds: delay.toInt()),
      child: SlideAnimation(
        verticalOffset: 50.0,
        duration: duration,
        child: FadeInAnimation(
          duration: duration,
          child: child,
        ),
      ),
    );
  }

  /// Creates a staggered animation for grid items
  static Widget staggeredGridItem({
    required Widget child,
    required int index,
    Duration duration = normalDuration,
    double delay = 100.0,
  }) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      duration: duration,
      columnCount: 2,
      child: ScaleAnimation(
        scale: 0.5,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }

  /// Creates a hero animation for navigation transitions
  static Widget heroTransition({
    required String tag,
    required Widget child,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  /// Creates a page transition animation
  static PageRouteBuilder createPageRoute({
    required Widget page,
    Duration duration = normalDuration,
    PageTransitionType type = PageTransitionType.slideUp,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case PageTransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          case PageTransitionType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: slideCurve)),
              child: child,
            );
          case PageTransitionType.slideRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: slideCurve)),
              child: child,
            );
          case PageTransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: bounceCurve)),
              child: child,
            );
        }
      },
    );
  }

  /// Creates a shimmer loading animation
  static Widget shimmerLoading({
    required Widget child,
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (value - 1).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a bounce animation for buttons
  static Widget bounceButton({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 100),
      builder: (context, value, child) {
        return GestureDetector(
          onTapDown: (_) {
            // Trigger scale down animation
          },
          onTapUp: (_) {
            onTap();
            // Trigger scale up animation
          },
          onTapCancel: () {
            // Trigger scale up animation
          },
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Creates a rotation animation
  static Widget rotateIn({
    required Widget child,
    Duration duration = normalDuration,
    double turns = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: turns),
      duration: duration,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Enum for different page transition types
enum PageTransitionType {
  fade,
  slideUp,
  slideRight,
  scale,
}

/// Custom animated container with multiple animation properties
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final bool animate;

  const AnimatedCard({
    super.key,
    required this.child,
    this.duration = AnimationUtils.normalDuration,
    this.curve = AnimationUtils.defaultCurve,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.animate = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        margin: widget.margin,
        decoration: widget.decoration,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              _slideAnimation.value.dy * 50,
            ),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                margin: widget.margin,
                decoration: widget.decoration,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
