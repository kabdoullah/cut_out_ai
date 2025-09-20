import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/widgets/connectivity_banner.dart';
import 'core/widgets/error_handler.dart';
import 'core/widgets/loading_overlay.dart';
import 'features/theme/providers/theme_provider.dart' hide ThemeMode;
import 'features/theme/providers/theme_provider.dart' as custom_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,

          // Configuration du thème
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _mapThemeMode(themeMode),

          // Configuration du router
          routerConfig: appRouter,

          // Wrapper avec gestion d'erreurs, loading et connectivité
          builder: (context, child) {
            return ErrorHandler(
              child: ConnectivityBanner(
                child: LoadingOverlay(
                  child: child ?? const SizedBox(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Conversion du ThemeMode custom vers Flutter ThemeMode
  ThemeMode _mapThemeMode(custom_theme.ThemeMode customThemeMode) {
    switch (customThemeMode) {
      case custom_theme.ThemeMode.light:
        return ThemeMode.light;
      case custom_theme.ThemeMode.dark:
        return ThemeMode.dark;
      case custom_theme.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
