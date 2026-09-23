import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'buttons.dart';
import 'header_decoration.dart';

/// Enveloppe dégradée utilisée en haut de la plupart des écrans (`.hd` maquette).
class GradientHeaderShell extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const GradientHeaderShell({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.vertical(bottom: Radius.circular(28)),
    this.padding = const EdgeInsets.only(bottom: 18),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Stack(
          children: [
            const HeaderDecoration(),
            SafeArea(
              bottom: false,
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rangée de navigation (retour / titre / actions) en tête d'un header dégradé.
class HeaderNavBar extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const HeaderNavBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = true,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(8, 4, 14, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showBack)
            CircleIconButton(icon: Icons.arrow_back_rounded, ghost: true, onPressed: () => Navigator.of(context).maybePop())
          else
            const SizedBox(width: 38),
          Expanded(
            child: Column(
              children: [
                if (title != null)
                  Text(title!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: TextStyle(color: Colors.white.withValues(alpha: .74), fontSize: 11)),
                  ),
              ],
            ),
          ),
          if (actions.isEmpty)
            const SizedBox(width: 38)
          else
            Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ),
    );
  }
}
