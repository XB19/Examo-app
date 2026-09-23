import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubjectMeta {
  final String name;
  final IconData icon;
  final Color color;
  const SubjectMeta(this.name, this.icon, this.color);
}

const kSubjects = <SubjectMeta>[
  SubjectMeta('Mathématiques', Icons.calculate_rounded, AppColors.mathBlue),
  SubjectMeta('Français', Icons.import_contacts_rounded, AppColors.frenchPurple),
  SubjectMeta('Physique-Chimie', Icons.science_rounded, AppColors.physicsTeal),
  SubjectMeta('SVT', Icons.eco_rounded, AppColors.svtGreen),
  SubjectMeta('Histoire-Géo', Icons.public_rounded, AppColors.historyBrown),
  SubjectMeta('Anglais', Icons.translate_rounded, AppColors.englishPink),
];

/// Pastille carrée colorée pour une matière (icône + fond teinté).
class SubjectBadge extends StatelessWidget {
  final SubjectMeta subject;
  final double size;
  const SubjectBadge({super.key, required this.subject, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: subject.color.withValues(alpha: .08), borderRadius: BorderRadius.circular(size * 0.29)),
      child: Icon(subject.icon, color: subject.color, size: size * 0.46),
    );
  }
}
