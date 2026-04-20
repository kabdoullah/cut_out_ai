import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'checkerboard_painter.dart';

const _kChipSelectedBorderWidth = 2.5;
const _kChipUnselectedBorderWidth = 1.0;

class BackgroundImagePicker extends StatefulWidget {
  final Uint8List? selectedImageBytes;
  final ValueChanged<Uint8List?> onImageSelected;
  final ImagePicker imagePicker;

  BackgroundImagePicker({
    super.key,
    required this.selectedImageBytes,
    required this.onImageSelected,
    ImagePicker? imagePicker,
  }) : imagePicker = imagePicker ?? ImagePicker();

  @override
  State<BackgroundImagePicker> createState() => _BackgroundImagePickerState();
}

class _BackgroundImagePickerState extends State<BackgroundImagePicker> {
  bool _isPicking = false;

  Future<void> _pickImage() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final picked = await widget.imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      widget.onImageSelected(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de lire l\'image sélectionnée'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

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
            'Image de fond',
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
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _ImageChip(
                  isSelected: widget.selectedImageBytes == null,
                  primaryColor: colorScheme.primary,
                  onTap: () => widget.onImageSelected(null),
                  child: CustomPaint(painter: const CheckerboardPainter()),
                ),
              ),
              if (widget.selectedImageBytes != null)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _ImageChip(
                    isSelected: true,
                    primaryColor: colorScheme.primary,
                    onTap: () => widget.onImageSelected(null),
                    child: Image.memory(
                      widget.selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: _isPicking ? null : _pickImage,
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
                  child: _isPicking
                      ? Padding(
                          padding: EdgeInsets.all(10.w),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(
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
}

class _ImageChip extends StatelessWidget {
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;
  final Widget child;

  const _ImageChip({
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
    required this.child,
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
            width: isSelected
                ? _kChipSelectedBorderWidth
                : _kChipUnselectedBorderWidth,
          ),
        ),
        child: ClipOval(child: child),
      ),
    );
  }
}
