import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/app_image.dart';

class ImageStatusWidget extends StatefulWidget {
  final AppImageStatus status;
  final VoidCallback? onRetry;

  const ImageStatusWidget({
    super.key,
    required this.status,
    this.onRetry,
  });

  @override
  State<ImageStatusWidget> createState() => _ImageStatusWidgetState();
}

class _ImageStatusWidgetState extends State<ImageStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Animer seulement si en cours de traitement
    if (widget.status.isProcessing) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ImageStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Gérer l'animation selon le nouveau statut
    if (widget.status.isProcessing && !oldWidget.status.isProcessing) {
      _animationController.repeat();
    } else if (!widget.status.isProcessing && oldWidget.status.isProcessing) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.status) {
      case AppImageStatus.pending:
        return _buildStatusChip(
          icon: Icons.schedule,
          label: 'En attente',
          color: colorScheme.outline,
          backgroundColor: colorScheme.surfaceContainerHighest,
        );

      case AppImageStatus.processing:
        return _buildStatusChip(
          icon: Icons.autorenew,
          label: 'Traitement IA...',
          color: colorScheme.primary,
          backgroundColor: colorScheme.primaryContainer,
          isAnimated: true,
        );

      case AppImageStatus.completed:
        return _buildStatusChip(
          icon: Icons.check_circle,
          label: 'Terminé avec succès',
          color: _getSuccessColor(colorScheme),
          backgroundColor: _getSuccessBackgroundColor(colorScheme),
        );

      case AppImageStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(
              icon: Icons.error,
              label: 'Échec du traitement',
              color: colorScheme.error,
              backgroundColor: colorScheme.errorContainer,
            ),
            if (widget.onRetry != null) ...[
              SizedBox(width: 12.w),
              _buildRetryButton(),
            ],
          ],
        );
    }
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    bool isAnimated = false,
  }) {
    Widget iconWidget = Icon(
      icon,
      size: 20.sp,
      color: color,
    );

    if (isAnimated) {
      iconWidget = AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: child,
          );
        },
        child: iconWidget,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IconButton(
        onPressed: widget.onRetry,
        icon: Icon(
          Icons.refresh,
          color: colorScheme.primary,
        ),
        iconSize: 20.sp,
        tooltip: 'Réessayer le traitement',
        padding: EdgeInsets.all(8.w),
        constraints: BoxConstraints(
          minWidth: 36.w,
          minHeight: 36.h,
        ),
      ),
    );
  }

  // Couleurs pour le succès (vert)
  Color _getSuccessColor(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFF16A34A) // Green 600
        : const Color(0xFF22C55E); // Green 500
  }

  Color _getSuccessBackgroundColor(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFDCFCE7) // Green 100
        : const Color(0xFF052E16); // Green 900
  }
}

// Widget alternatif plus simple si besoin
class SimpleImageStatusWidget extends StatelessWidget {
  final AppImageStatus status;

  const SimpleImageStatusWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(
        _getIconForStatus(status),
        size: 18.sp,
        color: _getColorForStatus(status, theme.colorScheme),
      ),
      label: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _getBackgroundColorForStatus(status, theme.colorScheme),
      side: BorderSide(
        color: _getColorForStatus(status, theme.colorScheme).withOpacity(0.3),
      ),
    );
  }

  IconData _getIconForStatus(AppImageStatus status) {
    switch (status) {
      case AppImageStatus.pending:
        return Icons.schedule;
      case AppImageStatus.processing:
        return Icons.autorenew;
      case AppImageStatus.completed:
        return Icons.check_circle;
      case AppImageStatus.failed:
        return Icons.error;
    }
  }

  Color _getColorForStatus(AppImageStatus status, ColorScheme colorScheme) {
    switch (status) {
      case AppImageStatus.pending:
        return colorScheme.outline;
      case AppImageStatus.processing:
        return colorScheme.primary;
      case AppImageStatus.completed:
        return const Color(0xFF16A34A); // Green
      case AppImageStatus.failed:
        return colorScheme.error;
    }
  }

  Color _getBackgroundColorForStatus(AppImageStatus status, ColorScheme colorScheme) {
    switch (status) {
      case AppImageStatus.pending:
        return colorScheme.surfaceContainerHighest;
      case AppImageStatus.processing:
        return colorScheme.primaryContainer;
      case AppImageStatus.completed:
        return const Color(0xFFDCFCE7); // Green 100
      case AppImageStatus.failed:
        return colorScheme.errorContainer;
    }
  }
}