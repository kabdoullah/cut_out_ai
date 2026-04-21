import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/app_image.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/theme_switcher.dart';
import '../../image_processing/providers/image_view_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _heroController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _orb1Controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _orb2Controller = AnimationController(
      duration: const Duration(seconds: 9),
      vsync: this,
    )..repeat(reverse: true);

    _heroController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = ref.watch(imageStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          AppConfig.appName,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          const ThemeSwitcher(),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          // Animated background orbs
          _buildAmbientBackground(isDark),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: ScaleTransition(
                    scale: _scaleIn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),

                        // Hero visual
                        _buildHeroVisual(context),
                        SizedBox(height: 32.h),

                        // Headline
                        _buildHeadline(context),
                        SizedBox(height: 8.h),

                        // Subheadline
                        Text(
                          'Supprime l\'arrière-plan en quelques secondes, directement sur ton téléphone.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Primary CTA
                        _buildPrimaryCTA(context),
                        SizedBox(height: 12.h),

                        // Secondary actions
                        if (stats.hasAnyImages) ...[
                          _buildSecondaryActions(context, stats),
                        ],

                        SizedBox(height: 32.h),

                        // Feature pills
                        _buildFeaturePills(context),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orb1Controller, _orb2Controller]),
      builder: (context, _) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: _AmbientOrbPainter(
              orb1Progress: _orb1Controller.value,
              orb2Progress: _orb2Controller.value,
              isDark: isDark,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroVisual(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: SizedBox(
        height: 210.h,
        child: AnimatedBuilder(
          animation: _heroController,
          builder: (context, _) {
            return CustomPaint(
              painter: _HeroSplitPainter(
                progress: _heroController.value,
                isDark: isDark,
              ),
              child: Stack(
                children: [
                  // "Avant" label — bottom-left
                  Positioned(
                    left: 16.w,
                    bottom: 14.h,
                    child: _buildHeroTag('Avant', false),
                  ),
                  // "Après" label — bottom-right
                  Positioned(
                    right: 16.w,
                    bottom: 14.h,
                    child: _buildHeroTag('Après', true),
                  ),
                  // AI badge — top-right
                  Positioned(
                    right: 14.w,
                    top: 14.h,
                    child: _buildAiBadge(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroTag(String label, bool isAfter) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAfter
            ? AppTheme.primaryViolet
            : Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✦',
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'IA',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Supprime\nl\'arrière-plan\n',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1.1,
              color: colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: 'avec l\'IA.',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1.1,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [AppTheme.primaryViolet, AppTheme.accentFuchsia],
                ).createShader(const Rect.fromLTWH(0, 0, 250, 50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCTA(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushToImagePicker(),
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: AppTheme.brandGradient,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryViolet.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
            SizedBox(width: 10.w),
            Text(
              'Choisir une photo',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context, ImageStats stats) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.pushToGallery(),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(
              '${stats.completed} création${stats.completed > 1 ? 's' : ''}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePills(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final features = [
      (Icons.offline_bolt_rounded, 'Local — 100% privé'),
      (Icons.speed_rounded, 'Ultra-rapide'),
      (Icons.high_quality_rounded, 'Haute précision'),
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: features
          .map(
            (f) => Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.$1, size: 14.sp, color: colorScheme.primary),
                  SizedBox(width: 6.w),
                  Text(
                    f.$2,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// Custom painter for ambient glow orbs in background
class _AmbientOrbPainter extends CustomPainter {
  final double orb1Progress;
  final double orb2Progress;
  final bool isDark;

  const _AmbientOrbPainter({
    required this.orb1Progress,
    required this.orb2Progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final orb1x = size.width * (0.1 + orb1Progress * 0.15);
    final orb1y = size.height * (0.1 + orb1Progress * 0.1);

    final orb2x = size.width * (0.85 - orb2Progress * 0.1);
    final orb2y = size.height * (0.5 + orb2Progress * 0.15);

    _drawOrb(
      canvas,
      Offset(orb1x, orb1y),
      size.width * 0.55,
      isDark
          ? AppTheme.primaryViolet.withValues(alpha: 0.12)
          : AppTheme.primaryViolet.withValues(alpha: 0.06),
    );
    _drawOrb(
      canvas,
      Offset(orb2x, orb2y),
      size.width * 0.5,
      isDark
          ? AppTheme.accentFuchsia.withValues(alpha: 0.08)
          : AppTheme.accentFuchsia.withValues(alpha: 0.04),
    );
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_AmbientOrbPainter old) =>
      old.orb1Progress != orb1Progress || old.orb2Progress != orb2Progress;
}

// Diagonal split "before / after" hero painter with animated glow line
class _HeroSplitPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _HeroSplitPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final tilt = size.height * 0.10;
    final cx = size.width * 0.5;

    // ── Left side ("before" — with photo background) ──────────────────────
    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(cx + tilt, 0)
      ..lineTo(cx - tilt, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.save();
    canvas.clipPath(leftPath);
    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF1E1B4B), const Color(0xFF3730A3)]
            : [const Color(0xFFC4B5FD), const Color(0xFF7C3AED)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), leftPaint);
    canvas.restore();

    // ── Right side ("after" — transparent checkerboard) ───────────────────
    final rightPath = Path()
      ..moveTo(cx + tilt, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(cx - tilt, size.height)
      ..close();

    canvas.save();
    canvas.clipPath(rightPath);
    _drawCheckerboard(canvas, size);
    canvas.restore();

    // ── Subject silhouette ─────────────────────────────────────────────────
    _drawSubject(canvas, size);

    // ── Animated glow divider ──────────────────────────────────────────────
    _drawGlowLine(canvas, size, cx, tilt);
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    const cell = 11.0;
    final light = Paint()
      ..color = isDark ? const Color(0xFF2D2D35) : const Color(0xFFE5E7EB);
    final dark = Paint()
      ..color = isDark ? const Color(0xFF1A1A22) : const Color(0xFFF3F4F6);
    var row = 0;
    for (var y = 0.0; y < size.height; y += cell) {
      var col = 0;
      for (var x = 0.0; x < size.width; x += cell) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, cell),
          (row + col).isEven ? light : dark,
        );
        col++;
      }
      row++;
    }
  }

  void _drawSubject(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Gradient fill — fully opaque on left, fades to ghost on right (cutout effect)
    final gradPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.42, 0.58, 1.0],
        colors: [
          const Color(0xFFE9D5FF),
          const Color(0xFFDDD6FE),
          const Color(0x88C4B5FD),
          const Color(0x22A78BFA),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Head
    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.20),
      size.height * 0.115,
      gradPaint,
    );

    // Shoulders / body
    final body = Path();
    final headBottom = cy - size.height * 0.085;
    body.moveTo(cx - size.height * 0.18, size.height * 0.92);
    body.quadraticBezierTo(
      cx - size.height * 0.19, headBottom + size.height * 0.05,
      cx - size.height * 0.13, headBottom,
    );
    body.quadraticBezierTo(cx, headBottom - size.height * 0.03, cx + size.height * 0.13, headBottom);
    body.quadraticBezierTo(
      cx + size.height * 0.19, headBottom + size.height * 0.05,
      cx + size.height * 0.18, size.height * 0.92,
    );
    body.close();
    canvas.drawPath(body, gradPaint);
  }

  void _drawGlowLine(Canvas canvas, Size size, double cx, double tilt) {
    final glowIntensity = 0.55 + 0.45 * math.sin(progress * 2 * math.pi);

    final top = Offset(cx + tilt, 0);
    final bottom = Offset(cx - tilt, size.height);

    // Outer soft glow
    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.accentFuchsia.withValues(alpha: 0.0),
          AppTheme.accentFuchsia.withValues(alpha: glowIntensity * 0.6),
          AppTheme.primaryViolet.withValues(alpha: glowIntensity * 0.6),
          AppTheme.accentFuchsia.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromPoints(top, bottom))
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(top, bottom, outerPaint);

    // Bright core line
    final corePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: glowIntensity * 0.9),
          Colors.white.withValues(alpha: glowIntensity * 0.9),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.75, 1.0],
      ).createShader(Rect.fromPoints(top, bottom))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(top, bottom, corePaint);
  }

  @override
  bool shouldRepaint(_HeroSplitPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
