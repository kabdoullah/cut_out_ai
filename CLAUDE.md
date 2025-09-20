# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CutOut AI is a Flutter application that removes backgrounds from images using the Remove.bg API. The app supports camera/gallery image selection, AI-powered background removal, and local gallery management with multi-platform support.

## Development Commands

### Core Commands
- `flutter run` - Start the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (macOS only)
- `flutter analyze` - Run static analysis and linting
- `flutter test` - Run unit tests
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Running with API Key
The app requires a Remove.bg API key to function:
```bash
flutter run --dart-define=REMOVEBG_API_KEY=your_api_key_here
```

### Linting and Analysis
- Uses `flutter_lints` for standard Flutter linting rules
- Custom lint rules via `custom_lint` and `riverpod_lint`
- Analysis configuration in `analysis_options.yaml`

## Architecture

### State Management
- **Riverpod** for state management throughout the app
- **ImageViewModel** (`lib/features/image_processing/providers/image_view_model.dart`) is the main orchestrator
- Provider-based dependency injection for services

### Navigation
- **GoRouter** for declarative navigation
- Route definitions in `lib/core/router/app_router.dart`
- Navigation extensions for type-safe routing

### Key Services
- **RemoveBgService** (`lib/core/services/removebg_service.dart`) - Handles Remove.bg API integration
- **ImageProcessingService** - Orchestrates image processing workflow
- **StorageService** - Local data persistence
- **ConnectivityService** - Internet connection monitoring
- **FileService** - File operations and management

### App Structure
```
lib/
├── core/                    # Core app infrastructure
│   ├── config/             # App configuration and constants
│   ├── models/             # Core data models (AppImage, AppState)
│   ├── providers/          # Core providers (connectivity)
│   ├── router/             # Navigation setup
│   ├── services/           # Core services
│   ├── theme/              # App theming
│   └── widgets/            # Reusable core widgets
└── features/               # Feature-based modules
    ├── gallery/            # Image gallery
    ├── home/               # Home page
    ├── image_picker/       # Camera/gallery selection
    ├── image_processing/   # Background removal workflow
    ├── result/             # Processing results
    └── theme/              # Theme management
```

### Data Flow
1. User selects image via `ImagePickerPage`
2. Navigation to `ProcessingPage` with image path
3. `ImageViewModel.processImage()` orchestrates:
   - Connectivity check
   - Remove.bg API call via `RemoveBgService`
   - Local storage via `StorageService`
   - State updates via Riverpod
4. Results displayed in `ResultPage`
5. Processed images accessible in `GalleryPage`

## Configuration

### Environment Variables
- `REMOVEBG_API_KEY` - Required Remove.bg API key
- `DEBUG` - Optional debug mode flag

### App Configuration
- API configuration in `lib/core/config/app_config.dart`
- 12MB image size limit (Remove.bg constraint)
- 45-second API timeout

### Dependencies
Key dependencies include:
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client
- `flutter_screenutil` - Responsive UI
- `image_picker` - Camera/gallery access
- `permission_handler` - Device permissions
- `connectivity_plus` - Network monitoring

## Development Notes

### API Integration
- Remove.bg API requires valid API key
- Error handling for quota limits, invalid keys, rate limiting
- Automatic credit monitoring via response headers

### State Management Patterns
- Use `ImageViewModel` for all image-related state changes
- Leverage provider selectors for UI reactivity
- Async operations handled via FutureProviders when appropriate

### Testing Strategy
- Widget tests in `test/widget_test.dart`
- Test framework: Flutter's built-in testing

### Platform Support
- Android: Minimum SDK 21
- iOS: Standard Flutter iOS support
- Web, Windows, macOS, Linux: Configured but not primary targets