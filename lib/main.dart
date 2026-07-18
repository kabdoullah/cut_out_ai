import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/config/app_config.dart';
import 'core/services/local_ml_background_removal_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/widgets/error_handler.dart';
import 'core/widgets/loading_overlay.dart';
import 'features/theme/providers/theme_provider.dart' hide ThemeMode;
import 'features/theme/providers/theme_provider.dart' as custom_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalMlBackgroundRemovalService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final useDynamicColor = ref.watch(custom_theme.dynamicColorEnabledProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,

              // Configuration du thème — palette de marque par défaut ;
              // "couleurs du système" harmonise avec le fond d'écran
              // (Material You, Android 12+) quand l'utilisateur l'active.
              theme: AppTheme.light(
                useDynamicColor && lightDynamic != null
                    ? lightDynamic.harmonized()
                    : null,
              ),
              darkTheme: AppTheme.dark(
                useDynamicColor && darkDynamic != null
                    ? darkDynamic.harmonized()
                    : null,
              ),
              themeMode: _mapThemeMode(themeMode),

              // Configuration du router
              routerConfig: appRouter,

              // Wrapper avec gestion d'erreurs, loading et connectivité
              builder: (context, child) {
                return ErrorHandler(
                  child: LoadingOverlay(child: child ?? const SizedBox()),
                );
              },
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
