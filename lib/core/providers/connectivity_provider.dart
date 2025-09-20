import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

// Provider du service de connectivité
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();

  // Nettoyer quand le provider est disposé
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// Provider du stream de connectivité
final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

// Provider du statut actuel
final currentConnectivityProvider = Provider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.currentStatus;
});

// Provider pour vérifier si connecté
final isConnectedProvider = Provider<bool>((ref) {
  final status = ref.watch(currentConnectivityProvider);
  return status == ConnectivityStatus.connected;
});
