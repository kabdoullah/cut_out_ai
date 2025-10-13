# CutOut AI

Application Flutter qui supprime l'arrière-plan des photos en utilisant l'intelligence artificielle via l'API Remove.bg.

## 📱 Fonctionnalités

- 📷 Prise de photo avec caméra ou sélection depuis la galerie
- 🤖 Suppression d'arrière-plan par IA (Remove.bg)
- 🎨 Support du mode clair/sombre
- 📂 Galerie locale des images traitées
- 🔄 Gestion des états (processing, completed, failed)
- 📤 Partage des créations
- 🌐 Vérification de connectivité Internet

## 🚀 Getting Started

### Prérequis

- Flutter SDK (>= 3.9.2)
- Dart SDK
- Un compte [Remove.bg](https://www.remove.bg/) avec une API key

### Installation

1. **Cloner le repository**
```bash
git clone https://github.com/votre-username/cutout_ai.git
cd cutout_ai
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer l'API Key**

Éditer le fichier `.env/dev.json`:
```bash
nano .env/dev.json
```

Remplacer `your_dev_api_key_here` par votre clé API Remove.bg.

4. **Lancer l'application**
```bash
flutter run --dart-define-from-file=.env/dev.json
```

## 🔐 Configuration de Sécurité

### ⚠️ IMPORTANT - Ne JAMAIS commit l'API key dans le code

L'API key Remove.bg est sensible et ne doit **JAMAIS** être committée dans le code source.

### Méthode Recommandée: --dart-define-from-file

Cette méthode permet de gérer plusieurs environnements facilement avec des fichiers JSON.

#### Configuration Initiale

1. **Développement** - Éditer `.env/dev.json`:
```bash
nano .env/dev.json
```

Remplacer `your_dev_api_key_here` par votre vraie clé API.

2. **Production** - Créer `.env/prod.json`:
```bash
cp .env/prod.json.example .env/prod.json
nano .env/prod.json
```

#### Utilisation Quotidienne

```bash
# Développement
flutter run --dart-define-from-file=.env/dev.json

# Build Release Android (Production)
flutter build appbundle --release \
  --dart-define-from-file=.env/prod.json \
  --obfuscate \
  --split-debug-info=build/debug-info

# Build Release iOS (Production)
flutter build ipa --release \
  --dart-define-from-file=.env/prod.json \
  --obfuscate \
  --split-debug-info=build/debug-info
```

### Méthode Alternative: --dart-define

Si vous préférez passer les variables manuellement:

```bash
# Développement
flutter run --dart-define=REMOVEBG_API_KEY=votre_cle_api_ici

# Build Release
flutter build appbundle --release \
  --dart-define=REMOVEBG_API_KEY=votre_cle_api_ici \
  --obfuscate \
  --split-debug-info=build/debug-info
```

### Configuration dans l'IDE

#### VS Code

Créer `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define-from-file=.env/dev.json"
      ]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define-from-file=.env/prod.json"
      ]
    }
  ]
}
```

#### Android Studio / IntelliJ

1. Run → Edit Configurations
2. Additional run args: `--dart-define-from-file=.env/dev.json`
3. Créer plusieurs configurations pour Dev/Staging/Prod

## 🔑 Obtenir une API Key Remove.bg

1. Créer un compte sur [Remove.bg](https://www.remove.bg/users/sign_up)
2. Aller dans [API Dashboard](https://www.remove.bg/api)
3. Copier votre API key

**Plans disponibles:**
- **Free**: 50 crédits/mois (idéal pour développement)
- **Payant**: Plus de crédits selon vos besoins

## 🏗️ Architecture du Projet

```
lib/
├── core/                    # Infrastructure de base
│   ├── config/             # Configuration (AppConfig)
│   ├── models/             # Modèles de données
│   ├── providers/          # Providers globaux
│   ├── router/             # Navigation (GoRouter)
│   ├── services/           # Services (API, Storage, etc.)
│   ├── theme/              # Thèmes de l'app
│   └── widgets/            # Widgets réutilisables
└── features/               # Fonctionnalités
    ├── gallery/            # Galerie d'images
    ├── home/               # Page d'accueil
    ├── image_picker/       # Sélection d'images
    ├── image_processing/   # Traitement d'images
    ├── result/             # Résultats
    └── theme/              # Gestion du thème
```

### State Management

- **Riverpod** pour la gestion d'état
- Providers pour l'injection de dépendances
- ViewModels pour la logique métier

### Navigation

- **GoRouter** pour la navigation déclarative
- Extensions pour le routing type-safe

## 📦 Build de Release avec Obfuscation

Pour protéger votre code lors du déploiement:

```bash
# Android App Bundle (Play Store)
flutter build appbundle --release \
  --dart-define-from-file=.env/prod.json \
  --obfuscate \
  --split-debug-info=build/debug-info

# Android APK (Pour tests)
flutter build apk --release \
  --dart-define-from-file=.env/prod.json \
  --obfuscate \
  --split-debug-info=build/debug-info

# iOS
flutter build ipa --release \
  --dart-define-from-file=.env/prod.json \
  --obfuscate \
  --split-debug-info=build/debug-info
```

## 🛡️ Bonnes Pratiques de Sécurité

### ✅ À FAIRE
- ✅ Utiliser `--dart-define-from-file` avec des fichiers JSON séparés
- ✅ Garder `.env/dev.json`, `.env/prod.json` dans `.gitignore`
- ✅ Committer uniquement les fichiers `.example`
- ✅ Utiliser l'obfuscation pour les builds de release
- ✅ Révoquer immédiatement les clés compromises
- ✅ Utiliser différentes clés pour dev/staging/production
- ✅ Monitorer l'utilisation de votre API key sur Remove.bg

### ❌ À ÉVITER
- ❌ Ne JAMAIS hardcoder les clés API dans le code
- ❌ Ne JAMAIS committer `.env/dev.json`, `.env/prod.json` dans Git
- ❌ Ne JAMAIS partager vos clés API publiquement
- ❌ Ne JAMAIS utiliser la même clé pour dev et production
- ❌ Ne JAMAIS laisser de `defaultValue` avec une vraie clé API

## 🆘 Que Faire si l'API Key est Compromise?

1. **Immédiatement**: Révoquer la clé sur [Remove.bg Dashboard](https://www.remove.bg/api)
2. Générer une nouvelle clé
3. Mettre à jour votre configuration locale (`.env/dev.json`, `.env/prod.json`)
4. Si committée dans Git:
   - Nettoyer l'historique Git (attention: opération destructive)
   - Ou créer un nouveau repository

## 🔍 Vérification de Sécurité

Avant chaque commit, vérifier:
```bash
# Rechercher des potentielles clés API hardcodées
git diff | grep -i "api.*key"

# S'assurer que .env n'est pas tracké
git status | grep ".env"
```

## 📱 Commandes Utiles

```bash
# Développement
flutter run --dart-define-from-file=.env/dev.json

# Analyse statique
flutter analyze

# Tests
flutter test

# Nettoyage
flutter clean

# Build APK de debug
flutter build apk --debug --dart-define-from-file=.env/dev.json
```

## 📄 Dépendances Principales

| Package | Version | Usage |
|---------|---------|-------|
| `flutter_riverpod` | ^3.0.0 | State management |
| `go_router` | ^16.2.1 | Navigation |
| `dio` | ^5.9.0 | HTTP client |
| `flutter_screenutil` | ^5.9.3 | Responsive UI |
| `image_picker` | ^1.2.0 | Sélection d'images |
| `permission_handler` | ^12.0.1 | Permissions |
| `connectivity_plus` | ^6.1.5 | Connectivité réseau |
| `share_plus` | ^10.1.2 | Partage |

## 🐛 Troubleshooting

### Erreur: "API Key not configured"

Vérifiez que:
1. Le fichier `.env/dev.json` existe
2. La clé `REMOVEBG_API_KEY` est remplie
3. Vous utilisez `--dart-define-from-file=.env/dev.json`

### Erreur: "File not found"

Assurez-vous d'être à la racine du projet:
```bash
ls -la .env/
```

### Problème de permissions (Android)

Si les permissions caméra/stockage ne fonctionnent pas:
1. Vérifier `android/app/src/main/AndroidManifest.xml`
2. Désinstaller et réinstaller l'app
3. Vérifier les paramètres de l'appareil

## 📚 Documentation Supplémentaire

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Remove.bg API Documentation](https://www.remove.bg/api)

## 📧 Support

Pour toute question:
- **Email**: abdoulaye@cutoutai.com
- **Issues**: [GitHub Issues](https://github.com/votre-username/cutout_ai/issues)

## 📜 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- [Remove.bg](https://www.remove.bg/) pour l'API de suppression d'arrière-plan
- La communauté Flutter pour les excellents packages
