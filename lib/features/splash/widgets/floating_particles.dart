import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smarthealth_shep/features/splash/constants/splash_animation_constants.dart';

/// Ultra-slow ambient particles for premium depth.
class FloatingParticles extends StatefulWidget {
  const FloatingParticles({super.key});

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _particles = List.generate(28, (i) {
      return _Particle(
        origin: Offset(rng.nextDouble(), rng.nextDouble()),
        phase: rng.nextDouble() * math.pi * 2,
        drift: 1 + rng.nextDouble() * 2,
        period: 4 + rng.nextDouble() * 4,
        size: 1.2 + rng.nextDouble() * 1.8,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlesPainter(
              t: _controller.value,
              particles: _particles,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.origin,
    required this.phase,
    required this.drift,
    required this.period,
    required this.size,
  });

  final Offset origin;
  final double phase;
  final double drift;
  final double period;
  final double size;
}

class _ParticlesPainter extends CustomPainter {
  const _ParticlesPainter({
    required this.t,
    required this.particles,
  });

  final double t;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(
        alpha: SplashAnimationConstants.particleOpacity,
      );

    for (final p in particles) {
      final angle = (t * (2 * math.pi / p.period)) + p.phase;
      final dx = math.cos(angle) * p.drift;
      final dy = math.sin(angle * 0.7) * p.drift;
      final x = (p.origin.dx * size.width + dx).clamp(0.0, size.width);
      final y = (p.origin.dy * size.height + dy).clamp(0.0, size.height);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) => oldDelegate.t != t;
}
