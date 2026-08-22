import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/fieldagent/edit_fieldagent_profile_service.dart';
import 'package:proplilly/fieldagent/providers/edit_fieldagent_profile_provider.dart';

class EditFieldAgentProfileScreen extends StatelessWidget {
  const EditFieldAgentProfileScreen({
    super.key,
    required this.initialName,
    required this.initialPhone,
    this.initialProfileImage,
  });

  final String initialName;
  final String initialPhone;
  final String? initialProfileImage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditFieldAgentProfileProvider(),
      child: _EditFieldAgentProfileView(
        initialName: initialName,
        initialPhone: initialPhone,
        initialProfileImage: initialProfileImage,
      ),
    );
  }
}

class _EditFieldAgentProfileView extends StatefulWidget {
  const _EditFieldAgentProfileView({
    required this.initialName,
    required this.initialPhone,
    this.initialProfileImage,
  });

  final String initialName;
  final String initialPhone;
  final String? initialProfileImage;

  @override
  State<_EditFieldAgentProfileView> createState() =>
      _EditFieldAgentProfileViewState();
}

class _EditFieldAgentProfileViewState
    extends State<_EditFieldAgentProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  String? _selectedImagePath;
  bool _networkImageFailed = false;

  static final _allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _avatarLetter {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  bool get _hasExistingNetworkImage {
    if (_networkImageFailed || _selectedImagePath != null) return false;
    final url = widget.initialProfileImage?.trim();
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme;
  }

  bool _isAllowedImage(String path) {
    final lower = path.toLowerCase();
    return _allowedExtensions.any(lower.endsWith);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    if (!_isAllowedImage(picked.path)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only JPG, JPEG, PNG, and WEBP images are supported.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _selectedImagePath = picked.path;
      _networkImageFailed = false;
    });
  }

  bool get _nameChanged =>
      _nameController.text.trim() != widget.initialName.trim();

  bool get _phoneChanged =>
      _phoneController.text.trim() != widget.initialPhone.trim();

  bool get _imageChanged => _selectedImagePath != null;

  bool get _hasChanges => _nameChanged || _phoneChanged || _imageChanged;

  Future<void> _update() async {
    FocusScope.of(context).unfocus();

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final formState = _formKey.currentState;
    if (formState == null) return;

    if (_nameChanged || _phoneChanged) {
      if (!formState.validate()) return;
    }

    final result =
        await context.read<EditFieldAgentProfileProvider>().updateProfile(
              name: _nameChanged ? _nameController.text : null,
              phone: _phoneChanged ? _phoneController.text : null,
              profileImagePath: _imageChanged ? _selectedImagePath : null,
            );

    if (!mounted) return;

    switch (result) {
      case EditFieldAgentProfileSuccess(:final message):
        final text = message?.trim();
        if (text != null && text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 600));
        }
        if (!mounted) return;
        Navigator.of(context).pop(true);
      case EditFieldAgentProfileFailure(:final message):
        final text = message?.trim();
        if (text != null && text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isDesktopLike = screenWidth >= 900;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 44.0);
    final topSpacing = (screenHeight * 0.04).clamp(16.0, 36.0);
    final cardPadding = (screenWidth * 0.042).clamp(16.0, 28.0);
    final titleFont = (screenWidth * 0.046).clamp(20.0, 30.0);
    final bodyFont = (screenWidth * 0.033).clamp(13.0, 17.0);
    final buttonHeight = (screenHeight * 0.07).clamp(48.0, 58.0);
    final sectionGap = (screenHeight * 0.018).clamp(10.0, 22.0);
    final textTheme = Theme.of(context).textTheme;
    final isLoading = context.watch<EditFieldAgentProfileProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: ProplillyAppBar.logoActions(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topSpacing,
            horizontalPadding,
            horizontalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktopLike ? 640 : 560),
              child: Card(
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: _EditProfileAvatar(
                            avatarLetter: _avatarLetter,
                            selectedImagePath: _selectedImagePath,
                            existingImageUrl: _hasExistingNetworkImage
                                ? widget.initialProfileImage?.trim()
                                : null,
                            onNetworkImageError: () {
                              if (mounted) {
                                setState(() => _networkImageFailed = true);
                              }
                            },
                            onPickImage: _pickProfileImage,
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        Text(
                          'Update your profile',
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: titleFont,
                          ),
                        ),
                        SizedBox(height: (sectionGap * 0.6).clamp(8.0, 14.0)),
                        Text(
                          'Change your name and phone number below.',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: bodyFont,
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(fontSize: bodyFont),
                            filled: false,
                          ),
                          validator: (value) {
                            if (!_nameChanged) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sectionGap),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!isLoading) _update();
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: 'Phone',
                            hintStyle: TextStyle(fontSize: bodyFont),
                            filled: false,
                          ),
                          validator: (value) {
                            if (!_phoneChanged) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sectionGap),
                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _update,
                            child: isLoading
                                ? SizedBox(
                                    height: bodyFont + 8,
                                    width: bodyFont + 8,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: bodyFont,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileAvatar extends StatelessWidget {
  const _EditProfileAvatar({
    required this.avatarLetter,
    required this.onPickImage,
    this.selectedImagePath,
    this.existingImageUrl,
    this.onNetworkImageError,
  });

  final String avatarLetter;
  final String? selectedImagePath;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final VoidCallback? onNetworkImageError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final selectedPath = selectedImagePath?.trim();
    final hasSelectedImage =
        selectedPath != null && selectedPath.isNotEmpty && File(selectedPath).existsSync();
    final networkUrl = existingImageUrl?.trim();
    final hasNetworkImage = !hasSelectedImage &&
        networkUrl != null &&
        networkUrl.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPickImage,
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              backgroundImage: hasSelectedImage
                  ? FileImage(File(selectedPath))
                  : hasNetworkImage
                      ? NetworkImage(networkUrl)
                      : null,
              onBackgroundImageError: hasNetworkImage
                  ? (_, __) => onNetworkImageError?.call()
                  : null,
              child: hasSelectedImage || hasNetworkImage
                  ? null
                  : Text(
                      avatarLetter,
                      style: theme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPickImage,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
