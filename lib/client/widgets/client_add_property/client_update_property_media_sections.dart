import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Property images for update flow with existing remote URLs and new local files.
class UpdatePropertyImagesSection extends StatelessWidget {
  const UpdatePropertyImagesSection({
    super.key,
    required this.existingImageUrls,
    required this.newImagePaths,
    required this.onExistingChanged,
    required this.onNewImagesChanged,
    this.errorText,
  });

  final List<String> existingImageUrls;
  final List<String> newImagePaths;
  final ValueChanged<List<String>> onExistingChanged;
  final ValueChanged<List<String>> onNewImagesChanged;
  final String? errorText;

  static const int _maxPhotos = 6;
  static final _allowedExtensions = {'.jpg', '.jpeg', '.png'};

  int get _totalCount => existingImageUrls.length + newImagePaths.length;

  bool _isAllowedImage(String path) {
    final lower = path.toLowerCase();
    return _allowedExtensions.any(lower.endsWith);
  }

  Future<void> _pickPhotos(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    final allowed = picked.where((x) => _isAllowedImage(x.path)).toList();
    if (allowed.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only JPG, JPEG, and PNG images are supported.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final remaining = _maxPhotos - _totalCount;
    if (remaining <= 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxPhotos photos allowed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final paths = allowed.take(remaining).map((x) => x.path).toList();
    onNewImagesChanged([...newImagePaths, ...paths]);
  }

  void _removeExisting(int index) {
    final updated = List<String>.from(existingImageUrls)..removeAt(index);
    onExistingChanged(updated);
  }

  void _removeNew(int index) {
    final updated = List<String>.from(newImagePaths)..removeAt(index);
    onNewImagesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final slots = <Widget>[];

    for (var i = 0; i < existingImageUrls.length; i++) {
      slots.add(
        _RemotePhotoTile(
          imageUrl: existingImageUrls[i],
          isMain: i == 0 && newImagePaths.isEmpty,
          onRemove: () => _removeExisting(i),
        ),
      );
    }

    for (var i = 0; i < newImagePaths.length; i++) {
      slots.add(
        _LocalPhotoTile(
          path: newImagePaths[i],
          isMain: existingImageUrls.isEmpty && i == 0,
          onRemove: () => _removeNew(i),
        ),
      );
    }

    if (_totalCount < _maxPhotos) {
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
          'Keep existing photos, add new ones, or remove images before updating.',
          style: theme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: theme.bodySmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

class UpdatePropertyDocumentsSection extends StatelessWidget {
  const UpdatePropertyDocumentsSection({
    super.key,
    required this.existingDocumentUrls,
    required this.newDocumentPaths,
    required this.onExistingChanged,
    required this.onNewDocumentsChanged,
  });

  final List<String> existingDocumentUrls;
  final List<String> newDocumentPaths;
  final ValueChanged<List<String>> onExistingChanged;
  final ValueChanged<List<String>> onNewDocumentsChanged;

  Future<void> _pickDocuments(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;

    final paths = result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
    if (paths.isEmpty) return;
    onNewDocumentsChanged([...newDocumentPaths, ...paths]);
  }

  void _removeExisting(int index) {
    final updated = List<String>.from(existingDocumentUrls)..removeAt(index);
    onExistingChanged(updated);
  }

  void _removeNew(int index) {
    final updated = List<String>.from(newDocumentPaths)..removeAt(index);
    onNewDocumentsChanged(updated);
  }

  Future<void> _openRemoteDocument(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openLocalDocument(BuildContext context, String path) async {
    final uri = Uri.file(path);
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final hasDocuments =
        existingDocumentUrls.isNotEmpty || newDocumentPaths.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Plot Documents',
          style: theme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _pickDocuments(context),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.55),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: PremiumDecorations.iconTile(AppColors.primary),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: AppColors.primaryDark,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Add Docs',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PDF, JPG, JPEG, or PNG',
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasDocuments) ...[
          const SizedBox(height: 14),
          ...existingDocumentUrls.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DocumentRow(
                onView: () => _openRemoteDocument(context, entry.value),
                onRemove: () => _removeExisting(entry.key),
              ),
            );
          }),
          ...newDocumentPaths.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DocumentRow(
                onView: () => _openLocalDocument(context, entry.value),
                onRemove: () => _removeNew(entry.key),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.onView,
    required this.onRemove,
  });

  final VoidCallback onView;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PremiumOutlineButton(
            label: 'View Document',
            onPressed: onView,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.textSecondary,
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

class _RemotePhotoTile extends StatelessWidget {
  const _RemotePhotoTile({
    required this.imageUrl,
    required this.isMain,
    required this.onRemove,
  });

  final String imageUrl;
  final bool isMain;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const _PhotoPlaceholder(),
            errorWidget: (_, __, ___) => const _PhotoPlaceholder(),
          ),
        ),
        if (isMain) _MainBadge(),
        _RemoveButton(onRemove: onRemove),
      ],
    );
  }
}

class _LocalPhotoTile extends StatelessWidget {
  const _LocalPhotoTile({
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
        if (isMain) _MainBadge(),
        _RemoveButton(onRemove: onRemove),
      ],
    );
  }
}

class _MainBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark.withValues(alpha: 0.85),
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: AppColors.white.withValues(alpha: 0.45),
      ),
    );
  }
}
