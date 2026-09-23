import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons.dart';
import '../widgets/diagrams.dart';
import 'photo_review_screen.dart';

class PhotoCaptureScreen extends StatelessWidget {
  const PhotoCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141C2B),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(center: const Alignment(0, -0.1), radius: 1.1, colors: [
                    const Color(0xFF2B3850),
                    const Color(0xFF101724),
                  ]),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                  child: Row(
                    children: [
                      CircleIconButton(icon: Icons.close_rounded, onPressed: () => Navigator.of(context).maybePop(), iconColor: Colors.white),
                      Expanded(
                        child: Column(children: const [
                          Text('Photographie ta réponse', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Question 7 · Mathématiques', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ]),
                      ),
                      CircleIconButton(icon: Icons.bolt_rounded, onPressed: () {}, iconColor: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .5),
                        border: Border.all(color: Colors.white.withValues(alpha: .2)),
                        borderRadius: BorderRadius.circular(11)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle, color: Color(0xFFF5A623), size: 15),
                      SizedBox(width: 8),
                      Text('Page bien cadrée', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.028,
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: .55), blurRadius: 40, offset: const Offset(0, 20)),
                        ]),
                        child: const NotebookPage(width: 260, height: 340),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text('Cadre toute la page de ton cahier.\nÉcris lisiblement, à l\'encre foncée.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 11, height: 1.6)),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .5), width: 2)),
                        clipBehavior: Clip.antiAlias,
                        child: const NotebookPage(width: 52, height: 52, radius: BorderRadius.zero),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PhotoReviewScreen())),
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .22),
                              border: Border.all(color: Colors.white.withValues(alpha: .6), width: 3)),
                          child: Center(child: Container(width: 60, height: 60, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
                        ),
                      ),
                      CircleIconButton(icon: Icons.flip_camera_android_outlined, onPressed: () {}, iconColor: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Text('1 page prise', style: TextStyle(color: AppColors.kx700, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .55),
                          border: Border.all(color: Colors.white.withValues(alpha: .22)),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.add, color: Colors.white, size: 13),
                        SizedBox(width: 6),
                        Text('Ajouter une page', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
