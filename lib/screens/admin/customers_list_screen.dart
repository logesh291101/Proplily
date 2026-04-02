import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_drawer.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  bool _isLoading = true;
  List<User> _customers = [];
  Map<String, int> _propertyCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final customers = await UserService().getCustomers();
    final properties = await PropertyService().getProperties();
    
    final counts = <String, int>{};
    for (var cust in customers) {
      counts[cust.id] = properties.where((p) => p.ownerId == cust.id).length;
    }

    if (mounted) {
      setState(() {
        _customers = customers;
        _propertyCounts = counts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(title: const Text('Customers List')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _customers.length,
            itemBuilder: (context, index) {
              final customer = _customers[index];
              final count = _propertyCounts[customer.id] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(customer.fullName[0], style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(customer.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            Text(customer.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Properties', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: count > 0 ? Colors.green.shade100 : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                            child: Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: count > 0 ? Colors.green.shade900 : Colors.black54)),
                          ),
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
}
