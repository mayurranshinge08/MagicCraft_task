import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class MagicalBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;

  const MagicalBackground({
    Key? key,
    required this.child,
    this.showParticles = true,
  }) : super(key: key);

  @override
  State<MagicalBackground> createState() => _MagicalBackgroundState();
}

class _MagicalBackgroundState extends State<MagicalBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _particles = List.generate(15, (index) => Particle());
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.midnightBlue,
            AppTheme.darkPurple,
            AppTheme.midnightBlue,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (widget.showParticles) ...[
            // Animated particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    _particles,
                    _particleController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            // Pulsing orbs
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: OrbPainter(_pulseController.value),
                  size: Size.infinite,
                );
              },
            ),
          ],
          widget.child,
        ],
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;

  Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 3 + 1;
    speed = math.Random().nextDouble() * 0.5 + 0.1;
    color =
        [
          AppTheme.shimmeringGold.withOpacity(0.6),
          AppTheme.lightPurple.withOpacity(0.4),
          Colors.white.withOpacity(0.3),
        ][math.Random().nextInt(3)];
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill;

      final x =
          (particle.x + animationValue * particle.speed) % 1.0 * size.width;
      final y = particle.y * size.height;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OrbPainter extends CustomPainter {
  final double pulseValue;

  OrbPainter(this.pulseValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = AppTheme.orbGradient.createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.8, size.height * 0.2),
              radius: 50 + pulseValue * 20,
            ),
          )
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      30 + pulseValue * 15,
      paint,
    );

    // Second orb
    final paint2 =
        Paint()
          ..shader = AppTheme.enchantedGradient.createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.1, size.height * 0.7),
              radius: 40 + pulseValue * 15,
            ),
          )
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.7),
      25 + pulseValue * 10,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
