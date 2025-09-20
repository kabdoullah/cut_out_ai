import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/connectivity_provider.dart';

class RetryConnectionDialog extends ConsumerStatefulWidget {
  const RetryConnectionDialog({super.key});

  @override
  ConsumerState<RetryConnectionDialog> createState() => _RetryConnectionDialogState();
}

class _RetryConnectionDialogState extends ConsumerState<RetryConnectionDialog> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: colorScheme.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          const Text('Pas de connexion'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Une connexion internet est nécessaire pour traiter les images avec Remove.bg.',
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Vérifiez votre WiFi ou vos données mobiles.',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Plus tard'),
        ),
        FilledButton(
          onPressed: _isRetrying ? null : _retryConnection,
          child: _isRetrying
              ? SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Réessayer'),
        ),
      ],
    );
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isRetrying = true;
    });

    try {
      final service = ref.read(connectivityServiceProvider);
      final hasConnection = await service.checkConnection();

      if (hasConnection) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Connexion rétablie !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Toujours pas de connexion'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }
}