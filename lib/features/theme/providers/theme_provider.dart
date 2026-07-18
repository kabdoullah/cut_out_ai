import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum pour les modes de thème
enum ThemeMode { light, dark, system }

// Provider pour la gestion du thème
class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    // Charger le thème au démarrage
    _loadTheme();
    return ThemeMode.system; // Valeur par défaut
  }

  // Charger le thème depuis les préférences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 2; // System par défaut
    state = ThemeMode.values[themeIndex];
  }

  // Sauvegarder le thème
  Future<void> _saveTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  // Changer le thème
  void setTheme(ThemeMode theme) {
    state = theme;
    _saveTheme(theme);
  }
}

// Provider avec la nouvelle syntaxe Riverpod 3.0
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

// Provider pour l'option "couleurs du système" (Material You / dynamic
// color). Désactivé par défaut pour garder l'identité de marque.
class DynamicColorNotifier extends Notifier<bool> {
  static const String _prefsKey = 'dynamic_color_enabled';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }
}

final dynamicColorEnabledProvider =
    NotifierProvider<DynamicColorNotifier, bool>(() {
      return DynamicColorNotifier();
    });
