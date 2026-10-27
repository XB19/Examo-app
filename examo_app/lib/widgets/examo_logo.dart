import 'package:flutter/material.dart';

/// Recadre le lockup fourni (icône + texte, 3171x898) sur sa partie icône
/// (carrée, à gauche du fichier) pour obtenir le pictogramme seul.
class ExamoIcon extends StatelessWidget {
  final double size;
  const ExamoIcon({super.key, this.size = 44});

  static const double _sourceW = 3171;
  static const double _sourceH = 898;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: SizedBox(
        width: size,
        height: size,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: size * (_sourceW / _sourceH),
          minWidth: size * (_sourceW / _sourceH),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo.png',
              height: size,
              fit: BoxFit.fitHeight,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lockup complet (icône + "Examo") tel que fourni, mis à l'échelle par hauteur.
class ExamoWordmark extends StatelessWidget {
  final double height;
  const ExamoWordmark({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo.png', height: height, fit: BoxFit.fitHeight);
  }
}

/// Icône + libellé "Examo" recomposés (utilisé dans les en-têtes clairs/foncés).
class ExamoBrand extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color color;
  const ExamoBrand({super.key, this.iconSize = 28, this.fontSize = 20, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExamoIcon(size: iconSize),
        SizedBox(width: iconSize * 0.28),
        Text(
          'Examo',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: color,
            height: 1,
          ),
        ),
      ],
    );
  }
}
