# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CutOut AI is a Flutter application that removes backgrounds from images using the Remove.bg API. The app supports camera/gallery image selection, AI-powered background removal, and local gallery management.

## Development Commands

```bash
flutter run --dart-define=REMOVEBG_API_KEY=your_key  # Required to run
flutter analyze                                        # Linting (flutter_lints + riverpod_lint)
flutter test                                           # Run tests
flutter build apk --dart-define=REMOVEBG_API_KEY=your_key
```

The API key is read at compile time via `String.fromEnvironment('REMOVEBG_API_KEY')`. Without it, `dioProvider` throws on first use.

## Architecture

### State Management (Riverpod 3.0)
- Uses Riverpod 3.0 `Notifier`/`NotifierProvider` syntax throughout (not legacy `StateNotifier`)
- **`imageViewModelProvider`** (`lib/features/image_processing/providers/image_view_model.dart`) is the central state store — all image operations go through `ImageViewModel`
- **`themeProvider`** (`lib/features/theme/providers/theme_provider.dart`) manages light/dark/system theme with `SharedPreferences` persistence
- Note: the app defines its own `ThemeMode` enum that conflicts with Flutter's. In `main.dart`, this is resolved with a `hide ThemeMode` import alias

### Navigation (GoRouter)
Routes are defined as constants in `AppRoutes` (`lib/core/router/app_router.dart`). The `AppRouterExtension` on `BuildContext` provides helper methods:
- `context.goToHome()` — replaces stack
- `context.pushToImagePicker()`, `context.pushToGallery()` — push onto stack
- `context.pushToProcessing(imagePath)`, `context.pushToResult(...)` — encode params as URI query strings
- Methods prefixed `goTo*` are deprecated; use `pushTo*` equivalents

### Data Flow
1. `ImagePickerPage` → user picks image
2. `ProcessingPage` receives `imagePath` via query param, calls `ImageViewModel.processImage()`
3. `ImageViewModel` → `ImageProcessingService.removeBackground()` → `RemoveBgService` (Remove.bg API) → `FileService.saveProcessedImage()`
4. On success, navigates to `ResultPage` with `originalPath` and `processedPath` as query params
5. `GalleryPage` reads from `completedImagesProvider` (filtered/sorted view of `imageViewModelProvider`)

### Core Services (all exposed as Riverpod providers)
- **`removeBgServiceProvider`** — wraps Dio, calls Remove.bg `/removebg` endpoint, returns `Uint8List`
- **`dioProvider`** — configured via `DioConfig` with 45s timeout, `RetryInterceptor` (2 retries, delays 2s/5s, only on 5xx/timeouts, not 402/403)
- **`storageServiceProvider`** — persists `List<AppImage>` to `SharedPreferences` as JSON
- **`fileServiceProvider`** — saves processed PNG bytes to app documents directory
- **`imageProcessingServiceProvider`** — composes `RemoveBgService` + `FileService`

### Key Models
- **`AppImage`** (`lib/core/models/app_image.dart`) — immutable, `Equatable`, has `id` (timestamp-based), `originalPath`, `processedPath`, `status: AppImageStatus`
- **`AppState`** (`lib/core/models/app_state.dart`) — immutable Equatable state with extension methods (`startProcessing`, `completeProcessing`, `failProcessing`) that return new instances
- **`AppImageStatus`** — enum: `pending | processing | completed | failed`

### UI Infrastructure
- `ScreenUtilInit` design size: 375x812 (iPhone X)
- App-level wrappers in `main.dart` builder: `ErrorHandler > ConnectivityBanner > LoadingOverlay`
- `ConnectivityService` + `ConnectivityBanner` monitor network state globally

## Configuration

- `lib/core/config/app_config.dart` — all constants (API URL, 12MB size limit, 45s timeout, max 100 stored images)
- Assets: `assets/icons/` (app icon), `assets/splash/` (splash screen)
- `flutter_native_splash` configured; `flutter_native_splash` package is commented out in dev_dependencies due to Gradle 8.7 incompatibility

## Platform Support
- Android: minSdk 21
- iOS: standard Flutter support
- Web/desktop: configured but not primary targets
