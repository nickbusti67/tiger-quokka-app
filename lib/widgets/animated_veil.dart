import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/theme.dart';

class AnimatedVeil extends StatefulWidget {
  final Widget child;
  final bool isRevealed;
  final Duration duration;
  final VoidCallback? onRevealComplete;

  const AnimatedVeil({
    super.key,
    required this.child,
    this.isRevealed = false,
    this.duration = const Duration(milliseconds: 1500),
    this.onRevealComplete,
  });

  @override
  State<AnimatedVeil> createState() => _AnimatedVeilState();
}

class _AnimatedVeilState extends State<AnimatedVeil>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _veilAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _veilAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRevealComplete?.call();
      }
    });

    if (widget.isRevealed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedVeil oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed && !oldWidget.isRevealed) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // The content that will be revealed
            Opacity(
              opacity: _veilAnimation.value,
              child: Transform.scale(
                scale: 0.9 + (_veilAnimation.value * 0.1),
                child: widget.child,
              ),
            ),
            
            // The veil layers
            if (_veilAnimation.value < 1.0) ...[
              // Left curtain
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(-MediaQuery.sizeOf(context).width * 0.5 * _veilAnimation.value, 0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppTheme.primaryDark.withValues(alpha: 0.95),
                          AppTheme.primaryDeep,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Right curtain
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(MediaQuery.sizeOf(context).width * 0.5 * _veilAnimation.value, 0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppTheme.primaryDark.withValues(alpha: 0.95),
                          AppTheme.primaryDeep,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            
            // Golden glow effect
            if (_glowAnimation.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.goldPrimary.withValues(alpha: 0.3 * _glowAnimation.value),
                          AppTheme.goldPrimary.withValues(alpha: 0.1 * _glowAnimation.value),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            
            // Particle effects
            if (_particleAnimation.value > 0 && _particleAnimation.value < 1.0)
              ...List.generate(12, (index) {
                final angle = (index / 12) * 2 * math.pi;
                final distance = 100 * _particleAnimation.value;
                return Positioned(
                  left: MediaQuery.sizeOf(context).width / 2 + math.cos(angle) * distance - 4,
                  top: MediaQuery.sizeOf(context).height / 2 + math.sin(angle) * distance - 4,
                  child: Opacity(
                    opacity: (1 - _particleAnimation.value) * 0.8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.goldPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class VeilOpeningText extends StatefulWidget {
  final String text;
  final bool animate;
  final TextStyle? style;

  const VeilOpeningText({
    super.key,
    required this.text,
    this.animate = true,
    this.style,
  });

  @override
  State<VeilOpeningText> createState() => _VeilOpeningTextState();
}

class _VeilOpeningTextState extends State<VeilOpeningText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Text(
              widget.text,
              style: widget.style ?? Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.goldLight,
                shadows: [
                  Shadow(
                    color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
