import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum ConnectivityStatus { connected, disconnected, checking }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.instance;

  StreamController<ConnectivityStatus>? _controller;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  ConnectivityStatus _lastStatus = ConnectivityStatus.checking;

  // Stream pour écouter les changements de connexion
  Stream<ConnectivityStatus> get connectivityStream {
    _controller ??= StreamController<ConnectivityStatus>.broadcast();
    return _controller!.stream;
  }

  // État actuel de la connexion
  ConnectivityStatus get currentStatus => _lastStatus;

  // Initialiser le service
  void initialize() {
    // Vérifier la connexion au démarrage
    _checkInitialConnection();

    // Écouter les changements de connectivité (WiFi, Mobile, etc.)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _handleConnectivityChange(results);
    });

    // Écouter les changements de connexion internet réelle
    _internetSubscription = _connectionChecker.onStatusChange.listen((
      InternetConnectionStatus status,
    ) {
      _handleInternetStatusChange(status);
    });
  }

  Future<void> _checkInitialConnection() async {
    try {
      final bool hasInternet = await _connectionChecker.hasConnection;
      final ConnectivityStatus status = hasInternet
          ? ConnectivityStatus.connected
          : ConnectivityStatus.disconnected;

      _updateStatus(status);
    } catch (e) {
      debugPrint('❌ Erreur vérification connexion initiale: $e');
      _updateStatus(ConnectivityStatus.disconnected);
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    debugPrint('📡 Changement connectivité: $results');

    // Si aucune connectivité, on est déconnecté
    if (results.contains(ConnectivityResult.none)) {
      _updateStatus(ConnectivityStatus.disconnected);
      return;
    }

    // Sinon, vérifier la connexion internet réelle
    _verifyInternetConnection();
  }

  void _handleInternetStatusChange(InternetConnectionStatus status) {
    debugPrint('🌐 Changement internet: $status');

    final ConnectivityStatus newStatus =
        status == InternetConnectionStatus.connected
        ? ConnectivityStatus.connected
        : ConnectivityStatus.disconnected;

    _updateStatus(newStatus);
  }

  Future<void> _verifyInternetConnection() async {
    _updateStatus(ConnectivityStatus.checking);

    try {
      final bool hasInternet = await _connectionChecker.hasConnection;
      final ConnectivityStatus status = hasInternet
          ? ConnectivityStatus.connected
          : ConnectivityStatus.disconnected;

      _updateStatus(status);
    } catch (e) {
      debugPrint('❌ Erreur vérification internet: $e');
      _updateStatus(ConnectivityStatus.disconnected);
    }
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_lastStatus != status) {
      _lastStatus = status;
      _controller?.add(status);

      debugPrint('📊 Statut connexion: ${_getStatusString(status)}');
    }
  }

  String _getStatusString(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return '✅ Connecté';
      case ConnectivityStatus.disconnected:
        return '❌ Déconnecté';
      case ConnectivityStatus.checking:
        return '🔄 Vérification...';
    }
  }

  // Vérifier manuellement la connexion
  Future<bool> checkConnection() async {
    try {
      _updateStatus(ConnectivityStatus.checking);
      final bool hasInternet = await _connectionChecker.hasConnection;

      final ConnectivityStatus status = hasInternet
          ? ConnectivityStatus.connected
          : ConnectivityStatus.disconnected;

      _updateStatus(status);
      return hasInternet;
    } catch (e) {
      debugPrint('❌ Erreur check connexion: $e');
      _updateStatus(ConnectivityStatus.disconnected);
      return false;
    }
  }

  // Obtenir les détails de connexion
  Future<Map<String, dynamic>> getConnectionDetails() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasInternet = await _connectionChecker.hasConnection;

      return {
        'hasInternet': hasInternet,
        'connectivityType': connectivityResults,
        'status': _lastStatus,
        'lastCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'hasInternet': false,
        'connectivityType': [ConnectivityResult.none],
        'status': ConnectivityStatus.disconnected,
        'error': e.toString(),
        'lastCheck': DateTime.now().toIso8601String(),
      };
    }
  }

  // Nettoyer les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _controller?.close();
    _controller = null;
  }
}
