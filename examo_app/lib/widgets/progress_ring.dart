import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double size;
  final double percent; // 0..1
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;
  final Widget? center;

  const ProgressRing({
    super.key,
    this.size = 100,
    required this.percent,
    this.trackColor = const Color(0x33FFFFFF),
    this.progressColor = AppColors.gold500,
    this.strokeWidth = 10,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              percent: percent,
              trackColor: trackColor,
              progressColor: progressColor,
              strokeWidth: strokeWidth,
            ),
          ),
          ?center,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.percent,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final progress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const start = -1.5708; // -90deg
    final sweep = 6.28319 * percent.clamp(0, 1);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.progressColor != progressColor;
}

class MiniRing extends StatelessWidget {
  final double size;
  final double percent;
  final Color color;
  final String label;
  const MiniRing({super.key, this.size = 46, required this.percent, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return ProgressRing(
      size: size,
      percent: percent,
      strokeWidth: 6,
      trackColor: const Color(0xFFEDF1F7),
      progressColor: color,
      center: Text(label,
          style: TextStyle(fontSize: size * 0.24, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.5)),
    );
  }
}
