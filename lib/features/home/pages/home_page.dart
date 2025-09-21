import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/app_image.dart';
import '../../../core/widgets/theme_switcher.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/share_bottom_sheet.dart';
import '../../image_processing/providers/image_view_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> 
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _featuresController;
  late Animation<double> _heroAnimation;
  late Animation<double> _featuresAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );

    _featuresAnimation = CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeOutBack,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await _heroController.forward();
    _featuresController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Surveiller les statistiques pour afficher des infos dynamiques
    final stats = ref.watch(imageStatsProvider);
    final isInitialized = ref.watch(appInitializationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: [
          const ThemeSwitcher(),
          SizedBox(width: 16.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal avec animation hero
              AnimatedBuilder(
                animation: _heroAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _heroAnimation,
                      child: Text(
                        'Supprime l\'arrière-plan\nde tes photos avec l\'IA',
                        style: theme.textTheme.heading1.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              // Card de fonctionnalités avec animation
              AnimatedBuilder(
                animation: _featuresAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _featuresAnimation.value,
                    child: FadeTransition(
                      opacity: _featuresAnimation,
                      child: _buildFeaturesCard(context),
                    ),
                  );
                },
              ),


              // Espace flexible pour pousser les boutons vers le bas
              SizedBox(height: 40.h),
              // Boutons d'actions avec animation retardée
              AnimatedBuilder(
                animation: _featuresAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _featuresController,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
                    )),
                    child: FadeTransition(
                      opacity: _featuresAnimation,
                      child: _buildActionButtons(context, stats, ref),
                    ),
                  );
                },
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildFeaturesCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Icône IA avec gradient animé
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_fix_high, 
                size: 36.sp, 
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Intelligence Artificielle',
              style: theme.textTheme.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildFeatureItem(
              context,
              Icons.psychology,
              'Technologie IA Avancée',
              'Algorithme de pointe pour la détection',
            ),
            _buildFeatureItem(
              context,
              Icons.speed,
              'Ultra-rapide',
              'Traitement en quelques secondes',
            ),
            _buildFeatureItem(
              context,
              Icons.high_quality,
              'Haute précision',
              'Détection automatique des contours',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ImageStats stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: _buildAnimatedStatItem(
                context,
                Icons.photo_library,
                stats.total.toDouble(),
                'Images traitées',
                isPercentage: false,
              ),
            ),
            Container(width: 1, height: 40.h, color: colorScheme.outline),
            Expanded(
              child: _buildAnimatedStatItem(
                context,
                Icons.check_circle,
                stats.successRate,
                'Taux de succès',
                isPercentage: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatItem(
    BuildContext context,
    IconData icon,
    double targetValue,
    String label, {
    required bool isPercentage,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _featuresAnimation,
      builder: (context, child) {
        final animatedValue = targetValue * _featuresAnimation.value;
        final displayValue = isPercentage 
            ? '${animatedValue.toStringAsFixed(0)}%'
            : '${animatedValue.toInt()}';

        return Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              displayValue,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ImageStats stats, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Bouton principal
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () => context.pushToImagePicker(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_photo_alternate_outlined),
                SizedBox(width: 8.w),
                Text(
                  stats.hasAnyImages ? 'Nouvelle photo' : 'Choisir une photo',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),

        // Bouton secondaire si l'utilisateur a des images
        if (stats.hasAnyImages) ...[
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: () => context.pushToGallery(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined),
                  SizedBox(width: 8.w),
                  Text(
                    'Voir mes ${stats.completed} création${stats.completed > 1 ? 's' : ''}',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Bouton partage rapide
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: OutlinedButton.icon(
              onPressed: () => _shareFromHome(context, ref),
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Partager mes créations'),
              style: OutlinedButton.styleFrom(
                textStyle: TextStyle(fontSize: 12.sp),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.subtitle.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.caption.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Partager depuis la page d'accueil
  void _shareFromHome(BuildContext context, WidgetRef ref) {
    final completedImages = ref.read(completedImagesProvider);
    
    if (completedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune création à partager')),
      );
      return;
    }

    // Extraire les chemins des images traitées
    final imagePaths = completedImages
        .where((img) => img.processedPath != null)
        .map((img) => img.processedPath!)
        .toList();

    if (imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image traitée à partager')),
      );
      return;
    }

    ShareBottomSheet.showForGallery(
      context: context,
      imagePaths: imagePaths,
      onShareComplete: () {
        print('Partage depuis HomePage terminé');
      },
    );
  }
}
