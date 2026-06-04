import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Property photo grid with add tile and main-photo badge on first image.
class AddPropertyImagesSection extends StatelessWidget {
  const AddPropertyImagesSection({
    super.key,
    required this.imagePaths,
    required this.onImagesChanged,
  });

  final List<String> imagePaths;
  final ValueChanged<List<String>> onImagesChanged;

  static const int _maxPhotos = 6;

  Future<void> _pickPhotos(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    final remaining = _maxPhotos - imagePaths.length;
    if (remaining <= 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum $_maxPhotos photos allowed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final paths = picked.take(remaining).map((x) => x.path).toList();
    onImagesChanged([...imagePaths, ...paths]);
  }

  void _removeAt(int index) {
    final updated = List<String>.from(imagePaths)..removeAt(index);
    onImagesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final slots = <Widget>[];

    for (var i = 0; i < imagePaths.length; i++) {
      slots.add(_PhotoTile(
        path: imagePaths[i],
        isMain: i == 0,
        onRemove: () => _removeAt(i),
      ));
    }

    if (imagePaths.length < _maxPhotos) {
      slots.add(_AddPhotoTile(onTap: () => _pickPhotos(context)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Property Images *',
          style: theme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Upload minimum 1 photo (recommended 2+). First image will be '
          'main display photo.',
          style: theme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          children: slots,
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: PremiumDecorations.iconTile(AppColors.primary),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Photos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.path,
    required this.isMain,
    required this.onRemove,
  });

  final String path;
  final bool isMain;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
          ),
        ),
        if (isMain)
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Main',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          right: 4,
          top: 4,
          child: Material(
            color: AppColors.white.withValues(alpha: 0.92),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
