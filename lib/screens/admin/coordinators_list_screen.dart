import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_drawer.dart';

class CoordinatorsListScreen extends StatefulWidget {
  const CoordinatorsListScreen({super.key});

  @override
  State<CoordinatorsListScreen> createState() => _CoordinatorsListScreenState();
}

class _CoordinatorsListScreenState extends State<CoordinatorsListScreen> {
  bool _isLoading = true;
  List<User> _coordinators = [];
  Map<String, int> _addedCounts = {};
  Map<String, int> _assignedCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final coordinators = await UserService().getCoordinators();
    final properties = await PropertyService().getProperties();
    
    final added = <String, int>{};
    final assigned = <String, int>{};

    for (var coord in coordinators) {
      added[coord.id] = properties.where((p) => p.ownerId == coord.id).length;
      assigned[coord.id] = properties.where((p) => p.assignedCoordinatorId == coord.id).length;
    }

    if (mounted) {
      setState(() {
        _coordinators = coordinators;
        _addedCounts = added;
        _assignedCounts = assigned;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(title: const Text('Coordinators List')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _coordinators.length,
            itemBuilder: (context, index) {
              final coord = _coordinators[index];
              final addedCount = _addedCounts[coord.id] ?? 0;
              final assignedCount = _assignedCounts[coord.id] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.indigo.withOpacity(0.1),
                            child: Text(coord.fullName[0], style: const TextStyle(fontSize: 24, color: Colors.indigo, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(coord.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(coord.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                Text(coord.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatWidget('Properties Added', addedCount, Colors.indigo),
                          _buildStatWidget('Assigned Tasks', assignedCount, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildStatWidget(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
