import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ChipTone { neutral, on, gold, ok, warn, crim, line, darkOn, darkOff }

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final ChipTone tone;
  final VoidCallback? onTap;
  final double height;
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = ChipTone.neutral,
    this.onTap,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;
    switch (tone) {
      case ChipTone.neutral:
        bg = AppColors.kx100;
        fg = AppColors.kx700;
        break;
      case ChipTone.on:
        bg = AppColors.kx700;
        fg = Colors.white;
        break;
      case ChipTone.gold:
        bg = AppColors.gold100;
        fg = const Color(0xFF7A6400);
        break;
      case ChipTone.ok:
        bg = AppColors.ok100;
        fg = AppColors.ok600;
        break;
      case ChipTone.warn:
        bg = AppColors.warn100;
        fg = AppColors.warn600;
        break;
      case ChipTone.crim:
        bg = AppColors.crim100;
        fg = AppColors.crim600;
        break;
      case ChipTone.line:
        bg = Colors.white;
        fg = AppColors.ink2;
        border = Border.all(color: AppColors.line);
        break;
      case ChipTone.darkOn:
        bg = Colors.white;
        fg = AppColors.kx700;
        break;
      case ChipTone.darkOff:
        bg = Colors.white.withValues(alpha: .15);
        fg = Colors.white;
        break;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99), border: border),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 6)],
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color bg;
  final Color fg;
  const Pill({super.key, required this.label, this.icon, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: fg), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}
