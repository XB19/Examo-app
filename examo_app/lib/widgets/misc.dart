import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Barre de progression horizontale arrondie (`.card` progress bars de la maquette).
class LinearBar extends StatelessWidget {
  final double percent; // 0..1
  final Color color;
  final double height;
  final Color track;
  const LinearBar({super.key, required this.percent, this.color = AppColors.kx700, this.height = 6, this.track = AppColors.line});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LayoutBuilder(builder: (context, c) {
        return Stack(children: [
          Container(height: height, color: track),
          Container(height: height, width: c.maxWidth * percent.clamp(0, 1), color: color),
        ]);
      }),
    );
  }
}

/// Vignette d'avatar élève (dégradé + silhouette), reprend le SVG généré côté maquette.
class StudentAvatar extends StatelessWidget {
  final double size;
  const StudentAvatar({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.kx300, AppColors.kx700],
          ),
        ),
        child: CustomPaint(painter: _AvatarPainter()),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: .92);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.39), size.width * 0.16, p);
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.92)
      ..cubicTo(size.width * 0.2, size.height * 0.66, size.width * 0.33, size.height * 0.54,
          size.width * 0.5, size.height * 0.54)
      ..cubicTo(size.width * 0.67, size.height * 0.54, size.width * 0.8, size.height * 0.66,
          size.width * 0.8, size.height * 0.92)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Icône de fichier notation (statistique) style `.stat` de la maquette.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const StatTile({super.key, required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: valueColor ?? AppColors.ink)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Vignette "annale" (couverture de sujet) : bandeau coloré + lignes de texte.
class ExamCover extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String year;
  const ExamCover({super.key, this.width = 60, this.height = 78, this.color = AppColors.kx700, this.year = '2024'});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: width,
        height: height,
        color: color.withValues(alpha: .06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: height * 0.34,
              color: color,
              padding: EdgeInsets.symmetric(horizontal: width * 0.14, vertical: height * 0.05),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ANNALE',
                        style: TextStyle(
                            fontSize: width * 0.115,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: .7),
                            letterSpacing: 1)),
                    SizedBox(height: height * 0.01),
                    Text(year,
                        style: TextStyle(fontSize: width * 0.22, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.14, vertical: height * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) {
                    final widths = [0.8, 1.0, 0.65, 0.9];
                    return FractionallySizedBox(
                      widthFactor: widths[i % widths.length],
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: .3), borderRadius: BorderRadius.circular(2)),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: width * 0.12, bottom: height * 0.08),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: width * 0.22,
                  height: width * 0.22,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(width * 0.07)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini graphique en barres (niveau par matière).
class MiniBarChart extends StatelessWidget {
  final List<(String, int, Color)> data; // label, percent 0-100, color
  final double height;
  const MiniBarChart({super.key, required this.data, this.height = 130});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final (label, pct, color) = d;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$pct%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 5),
                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: (pct / 100).clamp(0.06, 1.0),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Mini courbe (évolution de moyenne) — sparkline avec remplissage.
class Sparkline extends StatelessWidget {
  final List<double> values; // 0..1
  final Color color;
  final double height;
  const Sparkline({super.key, required this.values, this.color = AppColors.ok600, this.height = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) => CustomPaint(
          size: Size(c.maxWidth, height),
          painter: _SparklinePainter(values, color),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _SparklinePainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final dx = size.width / (values.length - 1);
    final points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(dx * i, size.height - values[i] * size.height),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }

    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: .26), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, linePaint);

    canvas.drawCircle(points.last, 3.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Onde audio statique (écran d'explication vocale).
class Waveform extends StatelessWidget {
  final double progress; // 0..1
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  const Waveform({
    super.key,
    required this.progress,
    this.activeColor = AppColors.gold500,
    this.inactiveColor = const Color(0x4DFFFFFF),
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final rnd = math.Random(7);
    final bars = List.generate(46, (i) => 0.2 + rnd.nextDouble() * 0.8);
    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, c) {
        final activeCount = (bars.length * progress).round();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(bars.length, (i) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.2),
                child: Container(
                  height: height * bars[i],
                  decoration: BoxDecoration(
                    color: i < activeCount ? activeColor : inactiveColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
