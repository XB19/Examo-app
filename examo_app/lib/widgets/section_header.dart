import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry margin;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.margin = const EdgeInsets.only(top: 22, bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 3, height: 14, margin: const EdgeInsets.only(right: 8), color: AppColors.kx700),
              Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
            ],
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.kx600)),
            ),
        ],
      ),
    );
  }
}
