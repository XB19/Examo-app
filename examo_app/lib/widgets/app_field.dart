import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Champ de saisie "en carte" fidèle à `.field` dans la maquette : icône,
/// libellé optionnel + valeur, et une icône de fin (chevron, check…).
class AppField extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final String value;
  final bool isPlaceholder;
  final Widget? trailing;
  final double height;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  const AppField({
    super.key,
    this.icon,
    this.label,
    this.value = '',
    this.isPlaceholder = false,
    this.trailing,
    this.height = 56,
    this.onTap,
    this.controller,
    this.obscure = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line, width: 1.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 19, color: AppColors.kx600), const SizedBox(width: 11)],
          Expanded(
            child: controller != null
                ? TextField(
                    controller: controller,
                    obscureText: obscure,
                    onChanged: onChanged,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: value,
                      hintStyle: const TextStyle(fontSize: 14.5, color: Color(0xFFA9A2BB), fontWeight: FontWeight.w500),
                      labelText: label,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (label != null)
                        Text(label!.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: .5)),
                      Text(value,
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.w600,
                              color: isPlaceholder ? const Color(0xFFA9A2BB) : AppColors.ink)),
                    ],
                  ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: content);
  }
}
