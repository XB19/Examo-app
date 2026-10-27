import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    // Police système (Roboto/San Francisco) : proche d'Inter visuellement,
    // et évite la dépendance native `google_fonts` -> `path_provider` -> `jni`
    // (son build CMake échoue sur un chemin de projet contenant des accents).
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.kx700,
      primary: AppColors.kx700,
      secondary: AppColors.gold500,
      surface: AppColors.white,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: AppColors.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
