import 'package:flutter/material.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_module_screen.dart';

class FieldAgentSchedulesScreen extends StatelessWidget {
  const FieldAgentSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldAgentModuleScreen(
      title: 'My schedule',
      subtitle: 'All assigned tasks with visit planning and actions.',
      icon: Icons.calendar_month_outlined,
      message: 'Your field schedules will appear here.',
    );
  }
}
