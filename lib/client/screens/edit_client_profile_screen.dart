import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/providers/edit_client_profile_provider.dart';
import 'package:proplilly/client/services/edit_client_profile_service.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
class EditClientProfileScreen extends StatelessWidget {
  const EditClientProfileScreen({
    super.key,
    required this.initialName,
    required this.initialPhone,
  });

  final String initialName;
  final String initialPhone;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditClientProfileProvider(),
      child: _EditClientProfileView(
        initialName: initialName,
        initialPhone: initialPhone,
      ),
    );
  }
}

class _EditClientProfileView extends StatefulWidget {
  const _EditClientProfileView({
    required this.initialName,
    required this.initialPhone,
  });

  final String initialName;
  final String initialPhone;

  @override
  State<_EditClientProfileView> createState() => _EditClientProfileViewState();
}

class _EditClientProfileViewState extends State<_EditClientProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

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

  Future<void> _update() async {
    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final result = await context.read<EditClientProfileProvider>().updateProfile(
          name: _nameController.text,
          phone: _phoneController.text,
        );

    if (!mounted) return;

    switch (result) {
      case EditClientProfileSuccess(:final message):
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
      case EditClientProfileFailure(:final message):
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
    final isLoading = context.watch<EditClientProfileProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: ProplillyAppBar.clientActions(),
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
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(fontSize: bodyFont),
                            filled: false,
                          ),
                          validator: (value) {
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
