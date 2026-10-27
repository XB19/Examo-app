import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reproduit les cercles/traits décoratifs semi-transparents du header dégradé
/// (voir `.hd .deco` dans la maquette HTML).
class HeaderDecorationPainter extends CustomPainter {
  const HeaderDecorationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Halo radial en haut à droite.
    final haloCenter = Offset(w * 0.846, h * 0.10);
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: .20), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: haloCenter, radius: w * 0.42));
    canvas.drawCircle(haloCenter, w * 0.42, halo);

    final ringPaintOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .16);
    canvas.drawCircle(haloCenter, w * 0.19, ringPaintOuter);
    canvas.drawCircle(
        haloCenter, w * 0.27, ringPaintOuter..color = Colors.white.withValues(alpha: .10));

    final goldRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold500.withValues(alpha: .28);
    canvas.drawCircle(Offset(w * 0.10, h * 0.86), w * 0.22, goldRing);

    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .10);
    final path = Path()
      ..moveTo(-w * 0.025, h * 0.66)
      ..cubicTo(w * 0.15, h * 0.56, w * 0.28, h * 0.70, w * 0.43, h * 0.63)
      ..cubicTo(w * 0.55, h * 0.58, w * 0.62, h * 0.66, w * 0.85, h * 0.44);
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeaderDecoration extends StatelessWidget {
  const HeaderDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: const HeaderDecorationPainter()),
      ),
    );
  }
}
