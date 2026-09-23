import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, gold, outline, dark }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool iconTrailing;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.iconTrailing = false,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 52,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.kx700;
        fg = Colors.white;
        shadow = [
          BoxShadow(color: AppColors.kx700.withValues(alpha: .26), blurRadius: 18, offset: const Offset(0, 8))
        ];
        break;
      case AppButtonVariant.gold:
        bg = AppColors.gold500;
        fg = const Color(0xFF3D2A00);
        shadow = [
          BoxShadow(color: AppColors.gold500.withValues(alpha: .34), blurRadius: 18, offset: const Offset(0, 8))
        ];
        break;
      case AppButtonVariant.outline:
        bg = Colors.white;
        fg = AppColors.kx700;
        border = Border.all(color: AppColors.kx300, width: 1.5);
        break;
      case AppButtonVariant.dark:
        bg = Colors.white.withValues(alpha: .16);
        fg = Colors.white;
        border = Border.all(color: Colors.white.withValues(alpha: .3));
        break;
    }

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && !iconTrailing) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 9)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize ?? 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
              color: fg,
            ),
          ),
        ),
        if (icon != null && iconTrailing) ...[const SizedBox(width: 9), Icon(icon, size: 18, color: fg)],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: border,
            boxShadow: shadow,
          ),
          child: content,
        ),
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final Color? color;
  const SmallButton({super.key, required this.label, this.icon, this.onPressed, this.filled = false, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.kx700;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onPressed,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: filled ? c : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: filled ? null : Border.all(color: AppColors.kx300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 14, color: filled ? Colors.white : c), const SizedBox(width: 6)],
              Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: filled ? Colors.white : c)),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool ghost;
  final bool solid;
  final Color? iconColor;
  final double size;
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.ghost = false,
    this.solid = false,
    this.iconColor,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;
    if (solid) {
      bg = Colors.white;
      fg = iconColor ?? AppColors.kx700;
      border = Border.all(color: AppColors.line);
    } else if (ghost) {
      bg = Colors.transparent;
      fg = iconColor ?? Colors.white;
    } else {
      bg = Colors.white.withValues(alpha: .14);
      fg = iconColor ?? Colors.white;
      border = Border.all(color: Colors.white.withValues(alpha: .18));
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border),
          child: Icon(icon, size: size * 0.52, color: fg),
        ),
      ),
    );
  }
}
