// import 'package:flutter/material.dart';
// import 'package:proplilly/client/theme/app_colors.dart';
// import 'package:proplilly/client/models/client_support_ticket_model.dart';
// import 'package:proplilly/client/theme/premium_decorations.dart';
// import 'package:proplilly/client/widgets/client_support_ticket/client_support_ticket_contact_row.dart';
//
// /// Direct assistance card with contact channels.
// class ClientSupportTicketAssistanceCard extends StatelessWidget {
//   const ClientSupportTicketAssistanceCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).textTheme;
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: AppColors.primaryLight.withValues(alpha: 0.28),
//         ),
//         boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: PremiumDecorations.iconTile(
//                   const Color(0xFF5C6BC0),
//                 ),
//                 child: const Icon(
//                   Icons.phone_in_talk_rounded,
//                   color: AppColors.primaryDark,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'Direct Assistance',
//                   style: theme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Text(
//             'Reach out to your dedicated property manager for any urgent '
//             'concerns or updates regarding your portfolio.',
//             style: theme.bodyMedium?.copyWith(
//               color: AppColors.textSecondary,
//               height: 1.45,
//             ),
//           ),
//           const SizedBox(height: 18),
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: AppColors.background,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: AppColors.primaryLight.withValues(alpha: 0.25),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Contact Information',
//                   style: theme.labelLarge?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.primaryDark,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ClientSupportTicketContactRow(
//                   icon: Icons.phone_android_rounded,
//                   label: ClientSupportTicketContent.phone,
//                   uri: Uri(scheme: 'tel', path: '+1234567890'),
//                   iconColor: const Color(0xFF5C6BC0),
//                 ),
//                 ClientSupportTicketContactRow(
//                   icon: Icons.email_outlined,
//                   label: ClientSupportTicketContent.email,
//                   uri: Uri(
//                     scheme: 'mailto',
//                     path: ClientSupportTicketContent.email,
//                   ),
//                   iconColor: AppColors.primary,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
