# CutOut AI

Application Flutter qui supprime l'arrière-plan des photos **directement sur l'appareil** grâce à l'intelligence artificielle — sans connexion Internet, sans API, sans limite.

## Fonctionnalités

- Prise de photo avec caméra ou sélection depuis la galerie
- Suppression d'arrière-plan par IA on-device (ONNX Runtime)
- Ajout d'une couleur de fond ou d'une image de fond personnalisée sur le résultat
- Sauvegarde dans la galerie système
- Galerie locale des images traitées
- Partage des créations
- Support mode clair/sombre

## Comment fonctionne l'IA on-device

### Vue d'ensemble

Au lieu d'envoyer l'image vers un serveur cloud (comme l'ancienne API Remove.bg), l'IA tourne **intégralement sur l'appareil**. Aucune image ne quitte le téléphone.

```
Image sélectionnée
       ↓
Chargement en mémoire (Uint8List)
       ↓
Inférence ONNX Runtime (on-device)
  → Modèle de segmentation embarqué
  → Génère un masque alpha pixel par pixel
       ↓
Composition PNG transparent (ui.Image → Uint8List)
       ↓
Sauvegarde locale (app documents directory)
```

### La pile technique

| Composant | Rôle |
|-----------|------|
| `image_background_remover` | Package Flutter qui orchestre le pipeline ML |
| `flutter_onnxruntime` | Runtime ONNX — exécute le modèle sur CPU/GPU |
| Modèle ONNX embarqué | Réseau de neurones de segmentation (~30 MB, inclus dans l'APK) |
| `BackgroundRemover.instance.removeBg()` | Entrée: `Uint8List` → Sortie: `ui.Image` avec canal alpha |

### Segmentation par canal alpha

Le modèle prédit pour chaque pixel une valeur de **0.0 à 1.0** (opacité). Les pixels correspondant au sujet sont conservés (alpha élevé), les pixels d'arrière-plan deviennent transparents (alpha = 0). Le résultat est exporté en PNG 32 bits (RGBA).

### Initialisation du modèle

Le modèle ONNX est chargé **une seule fois au démarrage** de l'application :

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalMlBackgroundRemovalService.initialize(); // chargement modèle
  runApp(const ProviderScope(child: MyApp()));
}
```

Les traitements suivants utilisent le modèle déjà en mémoire — pas de rechargement.

### Traitement d'une image (flux complet)

```
ImagePickerPage → processImage(path)
    → ImageViewModel.processImage()
        → ImageProcessingService.removeBackground()
            → LocalMlBackgroundRemovalService.removeBackground()
                → BackgroundRemover.instance.removeBg(bytes)  ← inférence ONNX
                → uiImage.toByteData(ImageByteFormat.png)     ← encodage PNG
            → FileService.saveProcessedImage()                ← sauvegarde locale
        → AppState.completeProcessing()
    → Navigation vers ResultPage
```

### Avantages vs API cloud

| Critère | On-device ML | API cloud (Remove.bg) |
|---------|-------------|----------------------|
| Connexion Internet | Non requise | Obligatoire |
| Limite d'utilisation | Illimitée | 50 crédits/mois gratuit |
| Coût | 0€ | Payant au-delà du quota |
| Confidentialité | Image reste sur l'appareil | Image envoyée au serveur |
| Taille APK | +30 MB (modèle embarqué) | Léger |
| Latence | Dépend du CPU/GPU appareil | Dépend du réseau |

### Prérequis plateforme

- **Android**: minSdk 21
- **iOS**: minimum iOS 16.0 (requis par `flutter_onnxruntime`)

---

## Installation

```bash
git clone https://github.com/kabdoullah/cut_out_ai.git
cd cutout_ai
flutter pub get
flutter run   # aucun --dart-define requis
```

### iOS uniquement

Créer `ios/Podfile` :

```ruby
platform :ios, '16.0'
use_frameworks! :linkage => :static
use_modular_headers!
```

Puis :

```bash
cd ios && pod install && cd ..
flutter run
```

Dans Xcode (Release) : **Strip Linked Product** → No.

---

## Build release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# iOS
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
```

---

## Architecture

```
lib/
├── core/
│   ├── config/             # AppConfig (limites taille image, etc.)
│   ├── models/             # AppImage, AppState, AppImageStatus
│   ├── router/             # GoRouter + extensions de navigation
│   ├── services/
│   │   ├── background_removal_service.dart      # Interface abstraite
│   │   ├── local_ml_background_removal_service.dart  # Implémentation ONNX
│   │   ├── image_processing_service.dart        # Orchestration
│   │   ├── file_service.dart                    # Sauvegarde fichiers
│   │   ├── gallery_service.dart                 # Export galerie système
│   │   └── storage_service.dart                 # Persistance SharedPrefs
│   ├── theme/
│   └── widgets/
└── features/
    ├── gallery/            # Galerie in-app
    ├── home/               # Page d'accueil
    ├── image_picker/       # Sélection source image
    ├── image_processing/   # Page de traitement + ViewModel
    ├── result/             # Résultat + couleur de fond + partage
    └── theme/              # Gestion thème clair/sombre
```

### State management

Riverpod 3.0 — `Notifier`/`NotifierProvider`. `ImageViewModel` est le store central pour toutes les opérations image.

### Swapper l'implémentation ML

L'architecture est conçue pour faciliter le remplacement du moteur ML :

```dart
// image_processing_service.dart
final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  return ImageProcessingService(
    backgroundRemovalService: LocalMlBackgroundRemovalService(), // ← changer ici
    fileService: ref.watch(fileServiceProvider),
  );
});
```

Toute classe qui implémente `BackgroundRemovalService` peut être branchée sans toucher au reste de l'app.

---

## Dépendances principales

| Package | Usage |
|---------|-------|
| `flutter_riverpod ^3.0.0` | State management |
| `go_router ^16.2.1` | Navigation |
| `image_background_remover ^2.0.0` | Pipeline ML on-device |
| `flutter_screenutil ^5.9.3` | UI responsive |
| `image_picker ^1.2.0` | Caméra / galerie |
| `gal ^2.3.2` | Export galerie système |
| `share_plus ^10.1.2` | Partage |
| `open_filex ^4.7.0` | Ouverture fichier après sauvegarde |

---

## Troubleshooting

### Build iOS échoue avec erreur linking

Vérifier que `ios/Podfile` contient `use_frameworks! :linkage => :static`.

### ANR sur premiers traitements (MIUI / appareils lents)

Normal au premier lancement si le modèle n'est pas encore chargé. Le modèle est initialisé au démarrage de l'app — les traitements suivants sont plus rapides.

### Image trop volumineuse

Limite : 10 MB. Réduire la résolution avant traitement ou utiliser `imageQuality` dans `image_picker`.

### Permissions caméra/galerie refusées

Désinstaller et réinstaller l'app, puis accorder les permissions au premier lancement.

---

## Support

- **Email**: abdoullahcoulibaly2@gmail.com
- **Issues**: [GitHub Issues](https://github.com/kabdoullah/cut_out_ai/issues)
