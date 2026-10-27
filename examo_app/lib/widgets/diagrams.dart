import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Schéma du triangle rectangle ABC utilisé dans les écrans de question.
class RightTriangleDiagram extends StatelessWidget {
  final double width;
  final double height;
  const RightTriangleDiagram({super.key, this.width = 150, this.height = 112});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _TrianglePainter()),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(size.width * 0.12, size.height * 0.84);
    final b = Offset(size.width * 0.84, size.height * 0.84);
    final c = Offset(size.width * 0.36, size.height * 0.16);

    final fill = Paint()..color = AppColors.kx100;
    final stroke = Paint()
      ..color = AppColors.kx700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    final tri = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    canvas.drawPath(tri, fill);
    canvas.drawPath(tri, stroke);

    // Petit carré d'angle droit.
    final sq = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(a.dx + size.width * 0.09, a.dy)
      ..lineTo(a.dx + size.width * 0.09, a.dy - size.width * 0.09);
    canvas.drawPath(sq, stroke..style = PaintingStyle.stroke);

    for (final p in [a, b, c]) {
      canvas.drawCircle(p, 3, Paint()..color = AppColors.kx700);
    }

    void tp(String s, Offset o, {double size = 12}) {
      final painter = TextPainter(
        text: TextSpan(text: s, style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: AppColors.kx700)),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, o);
    }

    tp('A', Offset(a.dx - 12, a.dy + 2));
    tp('B', Offset(b.dx + 2, b.dy + 2));
    tp('C', Offset(c.dx - 4, c.dy - 18));

    void tpMuted(String s, Offset o) {
      final painter = TextPainter(
        text: TextSpan(text: s, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, o);
    }

    tpMuted('8 cm', Offset((a.dx + b.dx) / 2 - 8, a.dy - 22));
    tpMuted('6 cm', Offset(a.dx - 2, (a.dy + c.dy) / 2 - 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simule une page de cahier quadrillé/ligné avec une écriture manuscrite
/// approximative, pour les écrans de capture photo / lecture OCR.
class NotebookPage extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius radius;
  const NotebookPage({super.key, this.width = 300, this.height = 380, this.radius = const BorderRadius.all(Radius.circular(10))});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFFFFEFA),
        child: CustomPaint(painter: _NotebookPainter()),
      ),
    );
  }
}

class _NotebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFFFFEFA));

    final margin = Paint()
      ..color = const Color(0xFFE4A9A2)
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(size.width * 0.09, 0), Offset(size.width * 0.09, size.height), margin);

    final ruleY = Paint()
      ..color = const Color(0xFFC9D9EE)
      ..strokeWidth = 1.2;
    final lineGap = size.height / 13;
    for (int i = 1; i < 13; i++) {
      canvas.drawLine(Offset(size.width * 0.11, lineGap * i), Offset(size.width * 0.96, lineGap * i), ruleY);
    }

    final hw = Paint()
      ..color = const Color(0xFF1B3560)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final rnd = <double>[4, -3, 6, -5, 3, -4, 5, -2];
    for (int row = 1; row < 12; row++) {
      final y = lineGap * row - lineGap * 0.34;
      final segments = 3 + (row % 3);
      final path = Path()..moveTo(size.width * 0.13, y);
      double x = size.width * 0.13;
      final segW = (size.width * 0.78) / segments;
      for (int s = 0; s < segments; s++) {
        x += segW;
        final wob = rnd[(row + s) % rnd.length];
        path.quadraticBezierTo(x - segW / 2, y + wob, x, y);
      }
      canvas.drawPath(path, hw);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
