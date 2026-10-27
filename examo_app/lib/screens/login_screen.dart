import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_field.dart';
import '../widgets/buttons.dart';
import '../widgets/examo_logo.dart';
import '../widgets/gradient_header.dart';
import '../root_shell.dart';
import 'exam_level_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool stayConnected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeaderShell(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
                padding: const EdgeInsets.only(bottom: 22),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ExamoBrand(iconSize: 32, fontSize: 27),
                      const SizedBox(height: 20),
                      const Text('Reprenons l\'entraînement',
                          style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.7)),
                      const SizedBox(height: 6),
                      Text('Connecte-toi pour retrouver ta progression',
                          style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Téléphone ou email', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink2)),
                    const SizedBox(height: 8),
                    const AppField(
                      icon: Icons.call_outlined,
                      value: '+228 90 42 18 07',
                      trailing: Icon(Icons.check_circle, color: AppColors.ok600, size: 18),
                    ),
                    const SizedBox(height: 16),
                    const Text('Mot de passe', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink2)),
                    const SizedBox(height: 8),
                    const AppField(
                      icon: Icons.lock_outline_rounded,
                      value: '••••••••',
                      trailing: Icon(Icons.visibility_outlined, color: AppColors.muted, size: 19),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => setState(() => stayConnected = !stayConnected),
                          child: Row(
                            children: [
                              Container(
                                width: 19,
                                height: 19,
                                decoration: BoxDecoration(
                                  color: stayConnected ? AppColors.kx700 : Colors.white,
                                  border: Border.all(color: stayConnected ? AppColors.kx700 : AppColors.line, width: 1.4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: stayConnected ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                              ),
                              const SizedBox(width: 9),
                              const Text('Rester connecté', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink2)),
                            ],
                          ),
                        ),
                        const Text('Mot de passe oublié ?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.kx600)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Se connecter',
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const RootShell()),
                        (route) => false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Créer un compte',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamLevelScreen())),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('ou continuer avec', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        ),
                        const Expanded(child: Divider(color: AppColors.line)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _socialButton('G', 'Google')),
                        const SizedBox(width: 12),
                        Expanded(child: _socialButton('', 'Apple', icon: Icons.apple)),
                        const SizedBox(width: 12),
                        Container(
                          width: 60,
                          height: 52,
                          decoration: BoxDecoration(
                              color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 21),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: AppColors.ink2, fontWeight: FontWeight.w600),
                          children: [
                            const TextSpan(text: 'Nouveau sur Examo ? '),
                            TextSpan(
                              text: 'Créer un compte',
                              style: const TextStyle(color: AppColors.kx700, fontWeight: FontWeight.w800),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => const ExamLevelScreen())),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String letter, String label, {IconData? icon}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null ? Icon(icon, size: 19) : Text(letter, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
