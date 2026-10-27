import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../services/exam_api.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons.dart';
import '../widgets/gradient_header.dart';

/// Affiche le sujet officiel scanné, page par page, avec zoom à deux doigts.
class ExamPaperScreen extends StatefulWidget {
  final Exam exam;
  const ExamPaperScreen({super.key, required this.exam});

  @override
  State<ExamPaperScreen> createState() => _ExamPaperScreenState();
}

class _ExamPaperScreenState extends State<ExamPaperScreen> {
  int currentPage = 0;
  int attempt = 0;

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
              child: HeaderNavBar(title: exam.subjectName, subtitle: '${exam.level} · ${exam.sessionLabel}'),
            ),
            Expanded(
              child: exam.available && exam.pageCount > 0
                  ? PageView.builder(
                      itemCount: exam.pageCount,
                      onPageChanged: (i) => setState(() => currentPage = i),
                      itemBuilder: (_, i) => _page(i + 1),
                    )
                  : _message(
                      Icons.hourglass_top_rounded,
                      'Sujet en préparation',
                      'Ce sujet est en cours de téléchargement. Reviens dans quelques instants.',
                    ),
            ),
            if (exam.available) _footer(exam),
          ],
        ),
      ),
    );
  }

  Widget _page(int page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      child: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
              boxShadow: [BoxShadow(color: AppColors.kx900.withValues(alpha: .08), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              ExamApi.pageImageUrl(widget.exam, page),
              key: ValueKey('${widget.exam.id}-$page-$attempt'),
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const SizedBox(height: 260, child: Center(child: CircularProgressIndicator(color: AppColors.kx700))),
              errorBuilder: (_, _, _) => SizedBox(
                height: 300,
                child: _message(
                  Icons.wifi_off_rounded,
                  'Impossible d\'afficher le sujet',
                  'Vérifie ta connexion internet puis réessaie.',
                  onRetry: () => setState(() => attempt++),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer(Exam exam) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.zoom_in_rounded, size: 16, color: AppColors.muted),
          const SizedBox(width: 6),
          const Text('Écarte deux doigts pour agrandir', style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
          if (exam.pageCount > 1) ...[
            const SizedBox(width: 12),
            Text('Page ${currentPage + 1} / ${exam.pageCount}',
                style: const TextStyle(fontSize: 12, color: AppColors.kx700, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.kx300),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              SmallButton(label: 'Réessayer', icon: Icons.refresh_rounded, filled: true, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
