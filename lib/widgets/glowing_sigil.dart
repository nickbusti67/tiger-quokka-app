import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/theme.dart';
import '../models/models.dart';

class GlowingSigil extends StatefulWidget {
  final CompatibilitySymbol? symbol;
  final double size;
  final bool animate;
  final bool showPercentage;
  final int? percentage;

  const GlowingSigil({
    super.key,
    this.symbol,
    this.size = 120,
    this.animate = true,
    this.showPercentage = false,
    this.percentage,
  });

  @override
  State<GlowingSigil> createState() => _GlowingSigilState();
}

class _GlowingSigilState extends State<GlowingSigil>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.symbol?.color ?? AppTheme.goldPrimary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4 * _pulseAnimation.value),
                blurRadius: 30 * _pulseAnimation.value,
                spreadRadius: 5 * _pulseAnimation.value,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: _rotationAnimation.value * 0.5,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _SigilRingPainter(
                    color: color.withValues(alpha: 0.3),
                    strokeWidth: 1.5,
                  ),
                ),
              ),
              
              // Inner ring
              Transform.rotate(
                angle: -_rotationAnimation.value * 0.3,
                child: CustomPaint(
                  size: Size(widget.size * 0.75, widget.size * 0.75),
                  painter: _SigilRingPainter(
                    color: color.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashed: true,
                  ),
                ),
              ),
              
              // Center symbol
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Center(
                    child: widget.showPercentage && widget.percentage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.percentage}%',
                                style: TextStyle(
                                  color: color,
                                  fontSize: widget.size * 0.18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.symbol != null)
                                Text(
                                  widget.symbol!.emoji,
                                  style: TextStyle(fontSize: widget.size * 0.12),
                                ),
                            ],
                          )
                        : Text(
                            widget.symbol?.emoji ?? '✧',
                            style: TextStyle(
                              fontSize: widget.size * 0.25,
                              shadows: [
                                Shadow(
                                  color: color.withValues(alpha: 0.8),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SigilRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool dashed;

  _SigilRingPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    if (dashed) {
      const dashCount = 24;
      const dashGap = math.pi / dashCount;
      for (int i = 0; i < dashCount; i++) {
        final startAngle = i * 2 * dashGap;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          dashGap * 0.7,
          false,
          paint,
        );
      }
    } else {
      canvas.drawCircle(center, radius, paint);
    }

    // Draw small decorative circles
    const decorCount = 8;
    for (int i = 0; i < decorCount; i++) {
      final angle = (i / decorCount) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(
        Offset(x, y),
        strokeWidth * 1.5,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MysticalDivider extends StatelessWidget {
  final double width;
  final Color? color;

  const MysticalDivider({
    super.key,
    this.width = 200,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? AppTheme.goldPrimary.withValues(alpha: 0.5);
    
    return SizedBox(
      width: width,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    dividerColor,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '✧',
              style: TextStyle(
                color: dividerColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    dividerColor,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double maxSize;

  const FloatingParticles({
    super.key,
    this.particleCount = 20,
    this.color = AppTheme.goldPrimary,
    this.maxSize = 4,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(widget.particleCount, (_) => _generateParticle());
  }

  _Particle _generateParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * widget.maxSize + 1,
      speed: _random.nextDouble() * 0.3 + 0.1,
      opacity: _random.nextDouble() * 0.5 + 0.2,
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
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            color: widget.color,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double animationValue;

  _ParticlesPainter({
    required this.particles,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final yOffset = (particle.y + animationValue * particle.speed) % 1.0;
      final x = particle.x * size.width;
      final y = yOffset * size.height;

      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
