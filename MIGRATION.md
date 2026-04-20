# Migration: Remove.bg API → On-Device ML

## Résumé

Remplacement de l'API cloud payante Remove.bg par le traitement local via `image_background_remover` (ONNX Runtime).

**Branche:** `feat/migrate-to-local-ml`

---

## Motivations

| Avant | Après |
|-------|-------|
| Remove.bg API (payant, 2 req/jour en gratuit) | On-device ML (gratuit, illimité) |
| Requête réseau obligatoire | 100% hors-ligne |
| Clé API à gérer (`--dart-define`) | Aucune configuration |
| +0 MB app | +30 MB app (modèle ONNX embarqué) |

---

## Fichiers supprimés

| Fichier | Raison |
|---------|--------|
| `lib/core/services/removebg_service.dart` | Remplacé par `LocalMlBackgroundRemovalService` |
| `lib/core/network/dio_config.dart` | Dio plus nécessaire |
| `lib/core/services/rate_limit_service.dart` | Limite API supprimée, ML illimité |
| `lib/core/providers/connectivity_provider.dart` | Plus de réseau |
| `lib/core/services/connectivity_service.dart` | Plus de réseau |
| `lib/core/widgets/connectivity_banner.dart` | Plus de réseau |
| `lib/core/widgets/connectivity_indicator.dart` | Plus de réseau |
| `lib/core/widgets/retry_connection_dialog.dart` | Plus de réseau |

---

## Fichiers créés

| Fichier | Rôle |
|---------|------|
| `lib/core/services/background_removal_service.dart` | Interface abstraite + `BackgroundRemovalException` |
| `lib/core/services/local_ml_background_removal_service.dart` | Implémentation ONNX on-device |

---

## Fichiers modifiés

| Fichier | Changements clés |
|---------|-----------------|
| `lib/core/services/image_processing_service.dart` | Dépend de `BackgroundRemovalService` (abstraction), plus `RemoveBgService` |
| `lib/features/image_processing/providers/image_view_model.dart` | `RemoveBgException` → `BackgroundRemovalException`, rate limit supprimé |
| `lib/features/image_picker/pages/image_picker_page.dart` | UI quota journalier supprimée |
| `lib/core/config/app_config.dart` | Constantes Remove.bg + AdMob inutilisées supprimées |
| `lib/features/image_processing/pages/processing_page.dart` | Labels "Envoi/Réception" → "Analyse/Finalisation", message erreur sans mention internet |
| `pubspec.yaml` | `dio` → `image_background_remover: ^2.0.0`, `flutter_launcher_icons` déplacé en `dev_dependencies` |
| `ios/Runner.xcodeproj/project.pbxproj` | `IPHONEOS_DEPLOYMENT_TARGET` 13.0 → 16.0 |

---

## Architecture — Seam de migration

```
ImageViewModel
    └── ImageProcessingService
            └── BackgroundRemovalService (abstract)  ← seam
                    └── LocalMlBackgroundRemovalService  ← implémentation active
```

Swapper l'implémentation = changer une seule ligne dans `imageProcessingServiceProvider`.

---

## Setup iOS requis

Créer `ios/Podfile` avec :

```ruby
platform :ios, '16.0'
use_frameworks! :linkage => :static
use_modular_headers!
```

Dans Xcode (Release/TestFlight) :
- "Strip Linked Product" → **No**
- "Strip Style" → **Non-Global-Symbols**

---

## Commandes de build

```bash
# Android (plus besoin de --dart-define)
flutter run
flutter build apk

# iOS
cd ios && pod install && cd ..
flutter run
```

---

## Dead code nettoyé (post-migration)

Providers supprimés: `processingImagesProvider`, `failedImagesProvider`, `processImageProvider`, `appInitializationProvider`, `shareServiceProvider`

Classes supprimées: `ImageMetadata`, `ImageProcessingException`, `SimpleImageStatusWidget`, `ShareConfig`, `ShareOption`, `StorageStats`

Méthodes supprimées: `refreshData()`, `setCurrentImage()`, `clearCurrentImage()` (ViewModel), `saveSettings/loadSettings/getStorageStats` (StorageService), `fileExists/cleanupOldFiles/getAppDirectorySize` (FileService), `checkAllPermissions/requestAllPermissions/isPermissionPermanentlyDenied/getPermissionStatusString` (PermissionService), `shareBeforeAfter/shareImageBytes` (ShareService), `getGalleryPath/hasGalleryAccess/requestGalleryAccess` (GalleryService), `openFileManager/openUrl/shareText` (DeviceService)

Extensions supprimées: `AppColors` (ColorScheme), `AppImageStatus.isPending`, `AppImageStatus.colorHex`

AppState getters supprimés: `withoutLoading`, `hasImages`, `hasError`, `hasCurrentImage`, `totalImages`, `lastImage`, `successfulImages`
