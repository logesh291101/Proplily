import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/models/client_user_profile.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

/// Gradient hero with avatar, welcome message, and user identity.
class ProfileHeroSection extends StatelessWidget {
  const ProfileHeroSection({
    super.key,
    required this.profile,
    this.onEditAvatar,
  });

  final UserProfile profile;
  final VoidCallback? onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final height = MediaQuery.sizeOf(context).height * 0.23;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: height - 44,
            decoration: BoxDecoration(
              gradient: PremiumDecorations.headerGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: PremiumDecorations.cardShadow(opacity: 0.16),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -36,
                  top: -24,
                  child: Icon(
                    Icons.blur_on,
                    size: 150,
                    color: AppColors.white.withValues(alpha: 0.07),
                  ),
                ),
                Positioned(
                  left: -28,
                  bottom: 40,
                  child: Icon(
                    Icons.blur_on,
                    size: 110,
                    color: AppColors.white.withValues(alpha: 0.05),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back!',
                          style: theme.titleMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.88),
                            fontWeight: FontWeight.bold,fontSize:22,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.headlineSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.email_outlined,
                        //       size: 16,
                        //       color: AppColors.white.withValues(alpha: 0.85),
                        //     ),
                        //     const SizedBox(width: 6),
                        //     Expanded(
                        //       child: Text(
                        //         profile.email,
                        //         maxLines: 1,
                        //         overflow: TextOverflow.ellipsis,
                        //         style: theme.bodyMedium?.copyWith(
                        //           color: AppColors.white.withValues(alpha: 0.9),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: _ProfileAvatar(
                profileImage: profile.profileImage,
                avatarLetter: profile.avatarLetter,
                onEdit: onEditAvatar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar({
    required this.avatarLetter,
    this.profileImage,
    this.onEdit,
  });

  final String avatarLetter;
  final String? profileImage;
  final VoidCallback? onEdit;

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(covariant _ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileImage != widget.profileImage) {
      _imageFailed = false;
    }
  }

  bool get _hasValidImageUrl {
    if (_imageFailed) return false;
    final url = widget.profileImage?.trim();
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = widget.profileImage?.trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.primary,
            backgroundImage: _hasValidImageUrl
                ? NetworkImage(imageUrl!)
                : null,
            onBackgroundImageError: (_, __) {
              if (mounted) {
                setState(() => _imageFailed = true);
              }
            },
            child: _hasValidImageUrl
                ? null
                : Text(
                    widget.avatarLetter,
                    style: theme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        // Positioned(
        //   right: 2,
        //   bottom: 2,
        //   child: Material(
        //     color: Colors.transparent,
        //     child: InkWell(
        //       onTap: onEdit,
        //       customBorder: const CircleBorder(),
        //       child: Ink(
        //         width: 36,
        //         height: 36,
        //         decoration: BoxDecoration(
        //           gradient: PremiumDecorations.buttonGradient,
        //           shape: BoxShape.circle,
        //           border: Border.all(color: AppColors.white, width: 2.5),
        //           boxShadow: [
        //             BoxShadow(
        //               color: AppColors.primary.withValues(alpha: 0.35),
        //               blurRadius: 8,
        //               offset: const Offset(0, 3),
        //             ),
        //           ],
        //         ),
        //         child: const Icon(
        //           Icons.edit_rounded,
        //           color: AppColors.white,
        //           size: 18,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
