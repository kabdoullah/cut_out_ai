import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/app_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/models/app_image.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/image_view_model.dart';
import '../widgets/image_status_widget.dart';

class ProcessingPage extends ConsumerStatefulWidget {
  final String imagePath;

  const ProcessingPage({super.key, required this.imagePath});

  @override
  ConsumerState<ProcessingPage> createState() => _ProcessingPageMVVMState();
}

class _ProcessingPageMVVMState extends ConsumerState<ProcessingPage>
    with TickerProviderStateMixin {
  late AnimationController _ring1Controller;
  late AnimationController _ring2Controller;
  late AnimationController _ring3Controller;
  late AnimationController _pulseController;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _ring1Controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _ring2Controller = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    )..repeat();

    _ring3Controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ring1Controller.dispose();
    _ring2Controller.dispose();
    _ring3Controller.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<AppState>(imageViewModelProvider, (previous, next) {
      final currentImage = next.currentImage;
      if (currentImage != null) {
        if (currentImage.status.isCompleted &&
            currentImage.processedPath != null) {
          context.replaceWithResult(
            originalPath: currentImage.originalPath,
            processedPath: currentImage.processedPath!,
            imageId: currentImage.id,
          );
        } else if (currentImage.status.isFailed) {
          _showErrorDialog(context, next.error ?? 'Erreur inconnue');
        }
      }
    });

    final state = ref.watch(imageViewModelProvider);
    final currentImage = state.currentImage;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (currentImage?.status.isProcessing == true)
            TextButton(
              onPressed: () => context.popOrGoHome(),
              child: const Text('Annuler'),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rings animation
              _buildRingsAnimation(colorScheme),
              SizedBox(height: 48.h),

              // Status
              if (currentImage != null) ...[
                ImageStatusWidget(
                  status: currentImage.status,
                  onRetry: currentImage.status.isFailed
                      ? () => ref
                            .read(imageViewModelProvider.notifier)
                            .retryProcessing(currentImage.id)
                      : null,
                ),
                SizedBox(height: 16.h),
              ],

              // Main text
              Text(
                _getStatusText(
                  currentImage?.status ?? AppImageStatus.processing,
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              Text(
                _getSubText(
                  currentImage?.status ?? AppImageStatus.processing,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),

              // Step indicators
              if (state.isLoading) _buildStepIndicators(context, currentImage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRingsAnimation(ColorScheme colorScheme) {
    return SizedBox(
      width: 180.w,
      height: 180.w,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _ring1Controller,
          _ring2Controller,
          _ring3Controller,
          _pulseController,
        ]),
        builder: (context, _) {
          return CustomPaint(
            painter: _RingsPainter(
              ring1Angle: _ring1Controller.value * 2 * math.pi,
              ring2Angle: -_ring2Controller.value * 2 * math.pi,
              ring3Scale: 0.85 + _ring3Controller.value * 0.08,
              pulseScale: 0.92 + _pulseController.value * 0.08,
              primaryColor: colorScheme.primary,
              secondaryColor: AppTheme.accentFuchsia,
              surfaceColor: colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, AppTheme.accentFuchsia],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_fix_high_rounded,
                  size: 28.sp,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicators(BuildContext context, AppImage? currentImage) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    const steps = [
      (Icons.image_search_rounded, 'Analyse'),
      (Icons.memory_rounded, 'IA'),
      (Icons.check_circle_rounded, 'Résultat'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: i == 1
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == 1
                        ? colorScheme.primary
                        : colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  steps[i].$1,
                  size: 18.sp,
                  color: i == 1
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                steps[i].$2,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: i == 1 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontWeight: i == 1 ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Padding(
              padding: EdgeInsets.only(bottom: 20.h, left: 8.w, right: 8.w),
              child: SizedBox(
                width: 32.w,
                child: Divider(
                  color: colorScheme.outline,
                  thickness: 1.5,
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _getStatusText(AppImageStatus status) {
    switch (status) {
      case AppImageStatus.pending:
        return 'Préparation...';
      case AppImageStatus.processing:
        return 'L\'IA traite votre image';
      case AppImageStatus.completed:
        return 'Traitement terminé !';
      case AppImageStatus.failed:
        return 'Quelque chose s\'est mal passé';
    }
  }

  String _getSubText(AppImageStatus status) {
    switch (status) {
      case AppImageStatus.pending:
        return 'Préparation du traitement';
      case AppImageStatus.processing:
        return 'L\'intelligence artificielle supprime l\'arrière-plan. Quelques secondes suffisent.';
      case AppImageStatus.completed:
        return 'Ton image est prête !';
      case AppImageStatus.failed:
        return 'Le traitement a échoué. Essaie avec une autre image.';
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(width: 8.w),
            const Text('Erreur de traitement'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.popOrGoHome();
            },
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(imageViewModelProvider.notifier).clearError();
              final currentImage =
                  ref.read(imageViewModelProvider).currentImage;
              if (currentImage != null) {
                ref
                    .read(imageViewModelProvider.notifier)
                    .retryProcessing(currentImage.id);
              }
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double ring1Angle;
  final double ring2Angle;
  final double ring3Scale;
  final double pulseScale;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;

  const _RingsPainter({
    required this.ring1Angle,
    required this.ring2Angle,
    required this.ring3Scale,
    required this.pulseScale,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Outer glow pulse
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.06 * pulseScale)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * pulseScale, glowPaint);

    // Ring 3 — outermost, slow scale pulse
    _drawDashedRing(
      canvas,
      center,
      maxRadius * 0.95 * ring3Scale,
      primaryColor.withValues(alpha: 0.15),
      2,
      24,
    );

    // Ring 2 — middle, counter-rotating arcs
    _drawArcRing(
      canvas,
      center,
      maxRadius * 0.78,
      secondaryColor.withValues(alpha: 0.3),
      ring2Angle,
      3,
    );

    // Ring 1 — inner, rotating arc
    _drawArcRing(
      canvas,
      center,
      maxRadius * 0.62,
      primaryColor.withValues(alpha: 0.6),
      ring1Angle,
      3.5,
    );

    // Inner circle background
    final innerPaint = Paint()
      ..color = surfaceColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.42, innerPaint);
  }

  void _drawDashedRing(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double strokeWidth,
    int dashCount,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final dashAngle = (2 * math.pi) / dashCount;
    final gapFraction = 0.35;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawArcRing(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double startAngle,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background ring
    paint.color = color.withValues(alpha: 0.15);
    canvas.drawCircle(center, radius, paint);

    // Arc with gradient sweep
    paint.shader = SweepGradient(
      colors: [Colors.transparent, color],
      stops: const [0.0, 1.0],
      transform: GradientRotation(startAngle),
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      math.pi * 1.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.ring1Angle != ring1Angle ||
      old.ring2Angle != ring2Angle ||
      old.ring3Scale != ring3Scale ||
      old.pulseScale != pulseScale;
}
