import 'package:cutout_ai/features/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dynamicColorToggleValue = 'dynamic_color_toggle';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final useDynamicColor = ref.watch(dynamicColorEnabledProvider);

    return PopupMenuButton<Object>(
      tooltip: 'Changer le thème',
      icon: Icon(
        _getIconForTheme(currentTheme),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (Object value) {
        if (value is ThemeMode) {
          ref.read(themeProvider.notifier).setTheme(value);
        } else if (value == _dynamicColorToggleValue) {
          ref
              .read(dynamicColorEnabledProvider.notifier)
              .setEnabled(!useDynamicColor);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: currentTheme == ThemeMode.light
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              const Text('Clair'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: currentTheme == ThemeMode.dark
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              const Text('Sombre'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.auto_mode,
                color: currentTheme == ThemeMode.system
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              const Text('Système'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _dynamicColorToggleValue,
          child: Row(
            children: [
              Icon(
                Icons.wallpaper_rounded,
                color: useDynamicColor
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Couleurs du système')),
              Switch(
                value: useDynamicColor,
                onChanged: (enabled) {
                  Navigator.of(context).pop();
                  ref
                      .read(dynamicColorEnabledProvider.notifier)
                      .setEnabled(enabled);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForTheme(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_mode;
    }
  }
}
