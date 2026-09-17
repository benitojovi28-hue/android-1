# MyWork

Application mobile MyWork — plateforme d'emploi pour candidats et recruteurs au Cameroun. Construite avec Flutter, Riverpod, go_router et Supabase.

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.44.x (Dart 3.12.x) — vérifiez avec `flutter --version`
- Un compte et projet [Supabase](https://supabase.com)
- Pour Android : Android Studio + Android SDK, un émulateur ou un appareil physique avec le débogage USB activé
- Pour iOS : **macOS avec Xcode** (le build iOS n'est pas possible depuis Linux/Windows) + un compte Apple Developer pour tester sur un appareil physique
- Exécutez `flutter doctor` et corrigez tout ce qui est signalé avant de continuer

Installez les dépendances du projet :

```bash
flutter pub get
```

## Configuration (variables d'environnement)

L'app lit sa configuration via `--dart-define-from-file` — aucune clé n'est committée dans le dépôt.

1. Copiez le fichier d'exemple :

   ```bash
   cp env/dev.json.example env/dev.json
   ```

2. Remplissez `env/dev.json` avec les valeurs de votre projet Supabase (Project Settings → API) :

   ```json
   {
     "SUPABASE_URL": "https://votre-projet.supabase.co",
     "SUPABASE_ANON_KEY": "votre-clé-anon-ou-publishable"
   }
   ```

`env/dev.json` est ignoré par git — ne le committez jamais.

## Lancer l'app

### Android

1. Branchez un appareil Android (USB, débogage activé) ou démarrez un émulateur.
2. Vérifiez qu'il est détecté :

   ```bash
   flutter devices
   ```

3. Lancez l'app en mode debug :

   ```bash
   flutter run -d <device-id> --dart-define-from-file=env/dev.json
   ```

   Omettez `-d <device-id>` s'il n'y a qu'un seul appareil/émulateur connecté.

### iOS

> Nécessite un Mac avec Xcode installé. Non réalisable depuis cet environnement Linux.

1. Sur macOS, installez les pods CocoaPods :

   ```bash
   cd ios && pod install && cd ..
   ```

2. Ouvrez `ios/Runner.xcworkspace` dans Xcode au moins une fois pour configurer votre équipe de signature (Signing & Capabilities), ou lancez directement :

   ```bash
   open -a Simulator   # pour tester sur simulateur, sinon branchez un iPhone
   flutter run -d <device-id> --dart-define-from-file=env/dev.json
   ```

3. Pour un appareil physique, sélectionnez votre équipe de développement dans Xcode (Runner target → Signing & Capabilities) avant de lancer, sinon le build échouera à la signature.

## Build de production

### Android

- App Bundle (recommandé pour le Play Store — Google génère les APK par ABI automatiquement) :

  ```bash
  flutter build appbundle --dart-define-from-file=env/dev.json
  ```

  Sortie : `build/app/outputs/bundle/release/app-release.aab`

- APK direct (installation manuelle, hors Play Store) :

  ```bash
  flutter build apk --split-per-abi --dart-define-from-file=env/dev.json
  ```

  Sortie : `build/app/outputs/flutter-apk/app-<abi>-release.apk` (un fichier par architecture, beaucoup plus léger qu'un APK universel)

> ⚠️ Avant toute publication sur le Play Store, `android/app/build.gradle.kts` doit être configuré avec un vrai keystore de release (actuellement signé avec le keystore de debug).

### iOS

Sur macOS uniquement :

```bash
flutter build ipa --dart-define-from-file=env/dev.json
```

Sortie : `build/ios/ipa/`. La distribution (TestFlight / App Store) se fait ensuite via Xcode Organizer ou `xcrun altool`/Transporter.

## Tests

```bash
flutter test
```

## Analyse statique

```bash
flutter analyze
```
