import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ExamoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ExamoBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_rounded, 'Accueil'),
    (Icons.menu_book_rounded, 'Annales'),
    (Icons.bar_chart_rounded, 'Progression'),
    (Icons.track_changes_rounded, 'Révisions'),
    (Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [BoxShadow(color: AppColors.kx900.withValues(alpha: .07), blurRadius: 22, offset: const Offset(0, -6))],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final (icon, label) = _items[i];
          final active = i == currentIndex;
          final color = active ? AppColors.kx700 : const Color(0xFF9B94AD);
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    width: 26,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.kx700 : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                    ),
                  ),
                  Icon(icon, size: 22, color: color),
                  const SizedBox(height: 4),
                  Text(label,
                      style: TextStyle(fontSize: 10.5, fontWeight: active ? FontWeight.w700 : FontWeight.w600, color: color)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
