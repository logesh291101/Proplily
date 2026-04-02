import 'package:flutter/material.dart';
import '../../models/subscription_model.dart';
import '../../models/user_model.dart';
import '../../services/subscription_service.dart';
import '../../widgets/admin_drawer.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/auth_theme.dart';

class PlansSubscribersScreen extends StatefulWidget {
  const PlansSubscribersScreen({super.key});

  @override
  State<PlansSubscribersScreen> createState() => _PlansSubscribersScreenState();
}

class _PlansSubscribersScreenState extends State<PlansSubscribersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Plans State
  List<PlanDetails> _plans = [];
  
  // Subscribers State
  bool _isLoadingSubscribers = true;
  List<Map<String, dynamic>> _allSubscribers = [];
  List<Map<String, dynamic>> _filteredSubscribers = [];
  String _selectedPlanFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() async {
    _plans = SubscriptionService().availablePlans;
    
    final customers = await UserService().getCustomers();
    final coordinators = await UserService().getCoordinators();
    final allUsers = [...customers, ...coordinators];

    // Mock Subscriber Mapping
    final subscribers = allUsers.map((user) {
      final isBasic = (user.id.hashCode % 2 == 0);
      final isActive = (user.id.hashCode % 3 != 0); // ~66% active
      
      return {
        'user': user,
        'planName': isBasic ? 'Basic Plan' : 'Premium Plan',
        'status': isActive ? 'Active' : 'Expired',
      };
    }).toList();

    if (mounted) {
      setState(() {
        _allSubscribers = subscribers;
        _filteredSubscribers = subscribers;
        _isLoadingSubscribers = false;
      });
    }
  }

  void _filterSubscribers(String filter) {
    setState(() {
      _selectedPlanFilter = filter;
      if (filter == 'All') {
        _filteredSubscribers = _allSubscribers;
      } else {
        _filteredSubscribers = _allSubscribers.where((s) => s['planName'] == filter).toList();
      }
    });
  }

  void _editPlanDialog(PlanDetails plan) {
    final titleController = TextEditingController(text: plan.title);
    final priceController = TextEditingController(text: plan.price.toString());
    final durationController = TextEditingController(text: plan.duration);
    final featuresController = TextEditingController(text: plan.features.join('\n'));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${plan.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Plan Name')),
                const SizedBox(height: 8),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (\$)'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Duration')),
                const SizedBox(height: 8),
                TextField(controller: featuresController, decoration: const InputDecoration(labelText: 'Features (one per line)'), maxLines: 4),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newFeatures = featuresController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
                SubscriptionService().updatePlan(
                  plan.planKey,
                  titleController.text,
                  double.tryParse(priceController.text) ?? plan.price,
                  durationController.text,
                  newFeatures,
                );
                setState(() {
                  _plans = SubscriptionService().availablePlans;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Plans & Subscribers'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Available Plans', icon: Icon(Icons.list_alt)),
            Tab(text: 'Subscribers List', icon: Icon(Icons.people_alt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlansTab(),
          _buildSubscribersTab(),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plan.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AuthTheme.primary)),
                    Text('\$${plan.price.toStringAsFixed(2)} / ${plan.duration}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Divider(height: 24),
                const Text('Features Included:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f)),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _editPlanDialog(plan),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Plan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscribersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('Filter By Plan:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedPlanFilter,
                  isExpanded: true,
                  items: ['All', 'Basic Plan', 'Premium Plan'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _filterSubscribers(val);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingSubscribers
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredSubscribers.length,
                itemBuilder: (context, index) {
                  final data = _filteredSubscribers[index];
                  final user = data['user'] as User;
                  final bool isActive = data['status'] == 'Active';
                  final String initials = user.fullName.isNotEmpty ? user.fullName[0] : '?';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AuthTheme.primary.withOpacity(0.1),
                        child: Text(initials, style: const TextStyle(color: AuthTheme.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(user.phoneNumber),
                          const SizedBox(height: 4),
                          Text('Plan: ${data['planName']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['status'],
                          style: TextStyle(
                            color: isActive ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
