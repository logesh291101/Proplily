// import 'package:flutter/material.dart';
// import 'package:proplilly/client/theme/app_colors.dart';
// import 'package:proplilly/client/models/client_user_profile.dart';
// import 'package:proplilly/client/theme/premium_decorations.dart';
// import 'package:proplilly/client/widgets/premium/premium_status_chip.dart';
//
// /// Premium subscription summary with plan, status, and key dates.
// class ProfileSubscriptionCard extends StatelessWidget {
//   const ProfileSubscriptionCard({super.key, required this.profile});
//
//   final UserProfile profile;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).textTheme;
//     final isActive = profile.subscriptionStatus == SubscriptionStatus.active;
//     final statusColor = isActive ? AppColors.success : AppColors.error;
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF5E2E6D),
//             AppColors.primary,
//             Color(0xFF9B5CAD),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: PremiumDecorations.cardShadow(opacity: 0.18),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppColors.white.withValues(alpha: 0.18),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.workspace_premium_rounded,
//                   color: AppColors.white,
//                   size: 26,
//                 ),
//               ),
//               const Spacer(),
//               PremiumStatusChip(
//                 label: profile.subscriptionStatus.label,
//                 color: statusColor,
//                 isPositive: isActive,
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Current Plan',
//             style: theme.labelMedium?.copyWith(
//               color: AppColors.white.withValues(alpha: 0.75),
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             profile.subscriptionPlan,
//             style: theme.headlineSmall?.copyWith(
//               color: AppColors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.white.withValues(alpha: 0.12),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: AppColors.white.withValues(alpha: 0.2),
//               ),
//             ),
//             child: Column(
//               children: [
//                 _DateRow(
//                   icon: Icons.calendar_month_outlined,
//                   label: 'Member Since',
//                   value: profile.memberSince,
//                 ),
//                 const SizedBox(height: 12),
//                 _DateRow(
//                   icon: Icons.event_available_outlined,
//                   label: isActive ? 'Renewal Date' : 'Expiry Date',
//                   value: profile.renewalDate,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DateRow extends StatelessWidget {
//   const _DateRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });
//
//   final IconData icon;
//   final String label;
//   final String value;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: AppColors.white.withValues(alpha: 0.85), size: 20),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             label,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: AppColors.white.withValues(alpha: 0.78),
//                 ),
//           ),
//         ),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                 color: AppColors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//         ),
//       ],
//     );
//   }
// }
