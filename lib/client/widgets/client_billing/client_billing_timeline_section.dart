// import 'package:flutter/material.dart';
// import 'package:proplilly/client/theme/app_colors.dart';
// import 'package:proplilly/client/models/client_billing_details.dart';
// import 'package:proplilly/client/theme/premium_decorations.dart';
//
// /// Vertical billing activity timeline.
// class BillingTimelineSection extends StatelessWidget {
//   const BillingTimelineSection({
//     super.key,
//     required this.activities,
//   });
//
//   final List<BillingActivity> activities;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: AppColors.primaryLight.withValues(alpha: 0.28),
//         ),
//         boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: PremiumDecorations.iconTile(AppColors.primary),
//                 child: const Icon(
//                   Icons.timeline_rounded,
//                   size: 18,
//                   color: AppColors.primaryDark,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 'Billing Activity',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.primaryDark,
//                     ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...List.generate(activities.length, (i) {
//             return _TimelineRow(
//               activity: activities[i],
//               isLast: i == activities.length - 1,
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// class _TimelineRow extends StatelessWidget {
//   const _TimelineRow({
//     required this.activity,
//     required this.isLast,
//   });
//
//   final BillingActivity activity;
//   final bool isLast;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).textTheme;
//
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: activity.color.withValues(alpha: 0.15),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: activity.color.withValues(alpha: 0.4),
//                   ),
//                 ),
//                 child: Icon(activity.icon, size: 18, color: activity.color),
//               ),
//               if (!isLast)
//                 Expanded(
//                   child: Container(
//                     width: 2,
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     color: AppColors.primaryLight.withValues(alpha: 0.45),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(bottom: isLast ? 8 : 18),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     activity.title,
//                     style: theme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     activity.date,
//                     style: theme.bodySmall?.copyWith(
//                       color: AppColors.textSecondary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
