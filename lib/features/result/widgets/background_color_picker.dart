import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'checkerboard_painter.dart';

class BackgroundColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final ValueChanged<Color?> onColorSelected;

  const BackgroundColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const List<Color?> _presets = [
    null, // transparent
    Colors.white,
    Colors.black,
    Color(0xFF9E9E9E), // gris
    Color(0xFFF44336), // rouge
    Color(0xFF4CAF50), // vert
    Color(0xFF2196F3), // bleu
    Color(0xFFFFEB3B), // jaune
    Color(0xFFFF9800), // orange
    Color(0xFF9C27B0), // violet
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Couleur de fond',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._presets.map(
                (color) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _ColorSwatch(
                    color: color,
                    isSelected: selectedColor == color,
                    onTap: () => onColorSelected(color),
                    primaryColor: colorScheme.primary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showMoreColors(context),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 18.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMoreColors(BuildContext context) {
    const moreColors = [
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
      Color(0xFF8BC34A),
      Color(0xFFFF5722),
      Color(0xFF607D8B),
      Color(0xFF795548),
      Color(0xFF3F51B5),
      Color(0xFF009688),
      Color(0xFFCDDC39),
      Color(0xFFFFC107),
      Color(0xFFB0BEC5),
      Color(0xFFFFCCBC),
      Color(0xFFD1C4E9),
      Color(0xFFB2EBF2),
      Color(0xFFDCEDC8),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SizedBox(
          width: 240.w,
          child: GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            children: moreColors
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onColorSelected(color);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: ClipOval(
          child: color == null
              ? CustomPaint(painter: const CheckerboardPainter())
              : ColoredBox(color: color!),
        ),
      ),
    );
  }
}
