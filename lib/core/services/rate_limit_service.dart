import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class RateLimitService {
  static const String _key = 'cutout_ai_rate_limit';

  String _todayString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
        '-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<bool> canMakeRequest() async {
    final today = _todayString();
    final data = await _load();
    if (data['date'] != today) return true;
    final count = (data['count'] as int?) ?? 0;
    return count < AppConfig.dailyRequestLimit;
  }

  /// Appelé UNIQUEMENT après un succès API.
  Future<void> recordRequest() async {
    final today = _todayString();
    final data = await _load();
    if (data['date'] != today) {
      await _save({'date': today, 'count': 1});
    } else {
      final count = (data['count'] as int?) ?? 0;
      await _save({'date': today, 'count': count + 1});
    }
  }

  Future<({int used, int limit})> getStatus() async {
    final today = _todayString();
    final data = await _load();
    if (data['date'] != today) {
      return (used: 0, limit: AppConfig.dailyRequestLimit);
    }
    final count = (data['count'] as int?) ?? 0;
    return (used: count, limit: AppConfig.dailyRequestLimit);
  }
}

final rateLimitServiceProvider = Provider<RateLimitService>((ref) {
  return RateLimitService();
});

final remainingRequestsProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(rateLimitServiceProvider);
  final status = await service.getStatus();
  return status.limit - status.used;
});
