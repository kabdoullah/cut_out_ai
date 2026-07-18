# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CutOut AI is a Flutter application that removes image backgrounds using **on-device** AI (ONNX Runtime) — no server, no API key, no network required. The app supports camera/gallery image selection, on-device background removal, custom background color/image compositing on the result, and local gallery management.

## Development Commands

```bash
flutter pub get
flutter run                       # No API key or --dart-define needed
flutter analyze                   # Linting (flutter_lints)
flutter test                      # Run tests
flutter build apk
```

Note: `riverpod_lint`/`custom_lint` are dev dependencies in `pubspec.yaml` but are **not** wired into `analysis_options.yaml` (no `analyzer: plugins:` section) — `flutter analyze` only runs `flutter_lints` today.

## Architecture

### On-device ML pipeline (no cloud API)
Background removal runs entirely on-device via `image_background_remover` (wraps `flutter_onnxruntime`). There is no network call, no Remove.bg, no Dio/HTTP client anywhere in the app.

- The ONNX model is loaded **once** at startup in `main()` via `LocalMlBackgroundRemovalService.initialize()`, before `runApp`. Subsequent processing reuses the already-loaded model.
- `LocalMlBackgroundRemovalService` (`lib/core/services/local_ml_background_removal_service.dart`) implements the `BackgroundRemovalService` interface (`lib/core/services/background_removal_service.dart`):
  1. Reads image bytes, enforces `AppConfig.maxImageSizeMB` (10MB)
  2. Runs ONNX inference on the **main isolate** via `BackgroundRemover.instance.removeBg(bytes)` — this call returns a `ui.Image` and must not be moved off the main isolate
  3. Exports raw RGBA (`ui.ImageByteFormat.rawRgba`) from the `ui.Image`, then hands the raw bytes to a background `Isolate.run` for PNG (DEFLATE) encoding, keeping the main thread free
- Swapping in a different removal backend means implementing `BackgroundRemovalService` and rebinding it in `imageProcessingServiceProvider` (`lib/core/services/image_processing_service.dart`) — nothing else in the data flow needs to change.

### State Management (Riverpod 3.0)
- Uses Riverpod 3.0 `Notifier`/`NotifierProvider` syntax throughout (not legacy `StateNotifier`)
- **`imageViewModelProvider`** (`lib/features/image_processing/providers/image_view_model.dart`) is the central state store — all image operations go through `ImageViewModel`
- **`themeProvider`** (`lib/features/theme/providers/theme_provider.dart`) manages light/dark/system theme with `SharedPreferences` persistence
- Note: the app defines its own `ThemeMode` enum that conflicts with Flutter's. In `main.dart`, this is resolved with a `hide ThemeMode` import alias

### Navigation (GoRouter)
Routes are defined as constants in `AppRoutes` (`lib/core/router/app_router.dart`). The `AppRouterExtension` on `BuildContext` provides helper methods:
- `context.goToHome()` — replaces stack
- `context.pushToImagePicker()`, `context.pushToGallery()` — push onto stack
- `context.pushToProcessing(imagePath)` — encodes params as URI query strings
- `context.pushToResult({originalPath, processedPath, imageId})` / `context.replaceWithResult(...)` — result route also carries `imageId` so the result page can write back an updated `processedPath` (e.g. after background compositing) via `ImageViewModel.updateProcessedPath`
- Methods prefixed `goTo*` (except `goToHome`) are deprecated; use `pushTo*` equivalents

### Data Flow
1. `ImagePickerPage` → user picks image
2. `ProcessingPage` receives `imagePath` via query param, calls `ImageViewModel.processImage(imagePath, imageName)`
3. `ImageViewModel.processImage`:
   - First persists the picker's transient cache file into permanent app storage via `ImageProcessingService.persistOriginalImage` (picker paths can be purged by the OS at any time — see doc comments in `FileService.persistOriginalImage`)
   - Creates an `AppImage`, adds it to state, marks it `processing`
   - Calls `ImageProcessingService.removeBackground()` → `LocalMlBackgroundRemovalService` (ONNX inference) → `FileService.saveProcessedImage()` (writes PNG to app documents dir)
   - Marks the image `completed`/`failed` and persists state via `StorageService`
4. On success, navigates to `ResultPage` with `originalPath`, `processedPath`, `imageId` as query params
5. On `ResultPage`, the user may pick a background color (`BackgroundColorPicker`) or image (`BackgroundImagePicker`); compositing happens off the main thread in `FileService.applyBackgroundColor`/`applyBackgroundImage` (decode → composite → PNG-encode inside `Isolate.run`). Saving/sharing with a background selected re-composites, writes a new file, and updates the stored `AppImage.processedPath` via `updateProcessedPath`
6. `GalleryPage` reads from `completedImagesProvider` (filtered/sorted view of `imageViewModelProvider`)

### Core Services (all exposed as Riverpod providers except the static ones noted)
- **`imageProcessingServiceProvider`** — composes `BackgroundRemovalService` (currently `LocalMlBackgroundRemovalService`) + `FileService`
- **`fileServiceProvider`** — saves processed/original images to the app documents directory; also does background color/image compositing
- **`storageServiceProvider`** — persists `List<AppImage>` to `SharedPreferences` as JSON (encode/decode offloaded to `Isolate.run`); auto-clears storage if corrupted JSON is detected on load
- **`GalleryService`** (static, not a provider) — saves images to the system gallery via `gal`, with a `permission_handler` fallback that branches on Android SDK version (Android 13+ uses `Permission.photos`, older uses `Permission.storage`)
- **`PermissionService`** (static, not a provider) — camera/gallery permission requests, separate from `GalleryService`'s own permission handling
- **`DeviceService`** — opens app settings (used when a permission is permanently denied)
- **`ShareService`** / `ShareBottomSheet` — share sheet for results

### Key Models
- **`AppImage`** (`lib/core/models/app_image.dart`) — immutable, `Equatable`, has `id` (timestamp-based), `originalPath`, `processedPath`, `status: AppImageStatus`
- **`AppState`** (`lib/core/models/app_state.dart`) — immutable Equatable state with extension methods (`startProcessing`, `completeProcessing`, `failProcessing`) that return new instances
- **`AppImageStatus`** — enum: `pending | processing | completed | failed`

### UI Infrastructure
- `ScreenUtilInit` design size: 375x812 (iPhone X)
- App-level wrappers in `main.dart` builder: `ErrorHandler > LoadingOverlay` (there is no connectivity banner/service — the app has no network dependency)

## Configuration

- `lib/core/config/app_config.dart` — constants (10MB image size limit, Play Store link)
- Assets: `assets/icons/` (app icon), `assets/splash/` (splash screen), `assets/fonts/` (Outfit, Nunito)
- `flutter_native_splash` config lives in `pubspec.yaml` but the package itself is commented out of `dev_dependencies` due to Gradle 8.7 incompatibility

## Platform Support
- Android: minSdk from Flutter default, targetSdk 35 (Play Store 2025 compliance)
- iOS: minimum deployment target 16.0 (required by `flutter_onnxruntime`)
- Web/desktop: configured but not primary targets
