import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/user_model.dart';
import '../../theme/auth_theme.dart';

class PropertyAssignmentScreen extends StatefulWidget {
  final User coordinator;

  const PropertyAssignmentScreen({super.key, required this.coordinator});

  @override
  State<PropertyAssignmentScreen> createState() => _PropertyAssignmentScreenState();
}

class _PropertyAssignmentScreenState extends State<PropertyAssignmentScreen> {
  // Mock data for unassigned properties
  final List<Property> _availableProperties = [
    Property(
      id: 'prop_1',
      propertyName: 'Palm Heights',
      propertyType: PropertyType.apartment,
      propertyAddress: 'Apt 201, 5th Main, HSR Layout, Bangalore',
      ownerName: 'Suresh Kumar',
      contactNumber: '+91 9000080000',
      latitude: 12.9103,
      longitude: 77.6450,
      ownerId: 'owner_1',
      createdAt: DateTime.now(),
    ),
    Property(
      id: 'prop_2',
      propertyName: 'Rose Garden',
      propertyType: PropertyType.independentHouse,
      propertyAddress: 'No 12, 2nd Cross, Indiranagar, Bangalore',
      ownerName: 'Meera Reddy',
      contactNumber: '+91 9888876666',
      latitude: 12.9784,
      longitude: 77.6408,
      ownerId: 'owner_2',
      createdAt: DateTime.now(),
    ),
  ];

  String _selectedFrequency = 'Weekly';
  final List<String> _frequencies = ['Daily', 'Weekly', 'Bi-weekly', 'Monthly'];
  final Set<String> _selectedPropertyIds = {};

  void _handleAssign() {
    if (_selectedPropertyIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one property')),
      );
      return;
    }
    
    // TODO: Implement assignment logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigned ${_selectedPropertyIds.length} properties to ${widget.coordinator.fullName} with $_selectedFrequency visits.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Assign Properties'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AuthTheme.primary.withOpacity(0.1),
                      child: Text(
                        widget.coordinator.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: AuthTheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Assign to: ${widget.coordinator.fullName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Visit Frequency',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AuthTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AuthTheme.inputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFrequency,
                      items: _frequencies.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedFrequency = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              'Select Properties',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableProperties.length,
              itemBuilder: (context, index) {
                final property = _availableProperties[index];
                final isSelected = _selectedPropertyIds.contains(property.id);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedPropertyIds.add(property.id);
                      } else {
                        _selectedPropertyIds.remove(property.id);
                      }
                    });
                  },
                  title: Text(property.propertyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(property.propertyAddress, style: const TextStyle(fontSize: 12)),
                  activeColor: AuthTheme.primary,
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _handleAssign,
              style: AuthTheme.primaryButton().copyWith(
                minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
              ),
              child: const Text('CONFIRM ASSIGNMENT'),
            ),
          ),
        ],
      ),
    );
  }
}
