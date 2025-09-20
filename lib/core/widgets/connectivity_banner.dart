import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';

class ConnectivityBanner extends ConsumerWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);

    return connectivityAsync.when(
      data: (status) => _buildWithConnectivityStatus(context, status),
      loading: () => child, // Pas de banner pendant le chargement initial
      error: (error, stack) {
        print('❌ Erreur connectivity stream: $error');
        return child;
      },
    );
  }

  Widget _buildWithConnectivityStatus(BuildContext context, ConnectivityStatus status) {
    if (status == ConnectivityStatus.connected) {
      return child; // Pas de banner si connecté
    }

    // Utiliser Stack pour éviter les problèmes d'overflow
    return Stack(
      children: [
        // Contenu principal inchangé
        child,
        // Banner positionné en haut comme overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildBanner(context, status),
        ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, ConnectivityStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    switch (status) {
      case ConnectivityStatus.disconnected:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        icon = Icons.wifi_off;
        message = 'Pas de connexion internet';
        break;
      case ConnectivityStatus.checking:
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        icon = Icons.wifi_find;
        message = 'Vérification de la connexion...';
        break;
      case ConnectivityStatus.connected:
        return const SizedBox.shrink(); // Ne pas afficher
    }

    return Material(
      elevation: 4,
      color: backgroundColor,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textColor,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}