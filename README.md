# Examo — app mobile Élève (frontend Flutter)

Frontend Flutter fidèle à `examo-maquettes.html`, écrans mobiles uniquement (390×844).
Aucun backend : les données affichées sont statiques, pour valider l'interface.

## Lancer le projet

```
cd examo_app
flutter pub get
flutter run            # choisir un appareil/émulateur Android ou iOS, ou "chrome"
```

## Structure

- `lib/theme/` — couleurs, typographie (Inter via `google_fonts`), thème Material.
- `lib/widgets/` — composants réutilisés sur tous les écrans (en-tête dégradé,
  boutons, chips, champs, carte, anneau de progression, mini-graphiques, etc.).
- `lib/screens/` — un fichier par écran de la maquette (23 écrans).
- `lib/root_shell.dart` — coquille avec la barre de navigation basse
  (Accueil / Annales / Progression / Révisions / Profil).

## Parcours de navigation

Splash → Onboarding → Connexion → (Créer un compte → Mon examen → Mes matières) →
Accueil (shell) → Épreuve (intro → question tapée/photo → résultat → correction →
explication IA écrite/vocale → fiche de remédiation) ; Notifications, Hors connexion
et Aide sont accessibles depuis l'Accueil / le Profil.

## À faire pour la prod

- Brancher une vraie source de données (API) à la place des valeurs statiques.
- `google_fonts` télécharge Inter au premier lancement (connexion requise une fois,
  puis mise en cache) ; pour un mode 100 % hors-ligne dès l'installation, embarquer
  les fichiers `.ttf` d'Inter dans `assets/fonts/` et les déclarer dans `pubspec.yaml`.
- Le logo (`assets/images/logo.png`) est recadré par code pour isoler le pictogramme ;
  fournir une version dédiée du pictogramme seul donnerait un rendu plus précis.
