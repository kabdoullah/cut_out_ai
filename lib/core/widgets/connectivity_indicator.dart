import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';

class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);

    return connectivityAsync.when(
      data: (status) => _buildIndicator(context, status),
      loading: () => _buildLoadingIndicator(context),
      error: (error, stack) => _buildErrorIndicator(context),
    );
  }

  Widget _buildIndicator(BuildContext context, ConnectivityStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color color;
    IconData icon;

    switch (status) {
      case ConnectivityStatus.connected:
        color = Colors.green;
        icon = Icons.wifi;
        break;
      case ConnectivityStatus.disconnected:
        color = colorScheme.error;
        icon = Icons.wifi_off;
        break;
      case ConnectivityStatus.checking:
        color = colorScheme.secondary;
        icon = Icons.wifi_find;
        break;
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Icon(
        icon,
        color: color,
        size: 16.sp,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      width: 16.w,
      height: 16.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(BuildContext context) {
    return Icon(
      Icons.error_outline,
      color: Theme.of(context).colorScheme.error,
      size: 16.sp,
    );
  }
}