import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/image_processing/providers/image_view_model.dart';
import '../models/app_image.dart';

// Overlay de chargement global
class LoadingOverlay extends ConsumerWidget {
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final currentImage = ref.watch(currentImageProvider);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 16.h),
                      Text(
                        _getLoadingMessage(currentImage),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getLoadingMessage(AppImage? currentImage) {
    if (currentImage == null) {
      return 'Chargement...';
    }

    switch (currentImage.status) {
      case AppImageStatus.processing:
        return 'Traitement de ${currentImage.name}\navec l\'intelligence artificielle...';
      default:
        return 'Préparation...';
    }
  }
}