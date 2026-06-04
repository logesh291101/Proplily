import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Dashed-border document upload area with file list.
class AddPropertyDocumentsSection extends StatelessWidget {
  const AddPropertyDocumentsSection({
    super.key,
    required this.documentPaths,
    required this.onDocumentsChanged,
  });

  final List<String> documentPaths;
  final ValueChanged<List<String>> onDocumentsChanged;

  Future<void> _pickDocuments(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;

    final paths = result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
    if (paths.isEmpty) return;
    onDocumentsChanged([...documentPaths, ...paths]);
  }

  void _removeAt(int index) {
    final updated = List<String>.from(documentPaths)..removeAt(index);
    onDocumentsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Documents *',
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
                    'PDF, images, or Word documents',
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (documentPaths.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...documentPaths.asMap().entries.map((entry) {
            final name = entry.value.split(RegExp(r'[/\\]')).last;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: PremiumDecorations.iconTile(AppColors.primary),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeAt(entry.key),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
