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

  // Toggle entre clair et sombre
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }
}

// Provider avec la nouvelle syntaxe Riverpod 3.0
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
