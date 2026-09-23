import 'package:flutter/material.dart';

/// Palette dérivée de la charte Examo (voir examo-maquettes.html).
class AppColors {
  AppColors._();

  static const kx900 = Color(0xFF0B1B38);
  static const kx800 = Color(0xFF12274C);
  static const kx700 = Color(0xFF1C3B72);
  static const kx600 = Color(0xFF2A5192);
  static const kx500 = Color(0xFF3A63A8);
  static const kx300 = Color(0xFF9FB6DB);
  static const kx100 = Color(0xFFE4ECF8);
  static const kx50 = Color(0xFFF2F6FC);

  static const gold600 = Color(0xFFB87700);
  static const gold500 = Color(0xFFF5A623);
  static const gold100 = Color(0xFFFFF0D4);

  static const crim700 = Color(0xFF8E2119);
  static const crim600 = Color(0xFFC2372C);
  static const crim100 = Color(0xFFFBE5E2);

  static const ink = Color(0xFF101A2E);
  static const ink2 = Color(0xFF414E68);
  static const muted = Color(0xFF6B7690);
  static const line = Color(0xFFE1E8F3);

  static const bg = Color(0xFFF4F6FB);
  static const white = Color(0xFFFFFFFF);

  static const ok600 = Color(0xFF17845A);
  static const ok100 = Color(0xFFDCF2E8);
  static const warn600 = Color(0xFF9A6B00);
  static const warn100 = Color(0xFFFFF2D8);

  // Matières (couleurs distinctives)
  static const mathBlue = Color(0xFF1C3B72);
  static const frenchPurple = Color(0xFF7A2E8E);
  static const physicsTeal = Color(0xFF0F6E8C);
  static const svtGreen = Color(0xFF17845A);
  static const historyBrown = Color(0xFFB05A00);
  static const englishPink = Color(0xFFB02E6B);

  static const gradient = LinearGradient(
    begin: Alignment(-0.8, -1),
    end: Alignment(0.9, 1),
    colors: [kx900, kx700, kx500],
    stops: [0.0, 0.48, 1.0],
  );
}
