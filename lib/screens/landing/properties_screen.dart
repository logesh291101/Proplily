import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = [
      _PropertyItem('Residential Villa', 'Bangalore', '₹1.2 Cr', '3BHK with modern amenities', Icons.home_rounded),
      _PropertyItem('Commercial Plot', 'Hyderabad', '₹85 L', 'Prime location', Icons.apartment),
      _PropertyItem('Apartment', 'Chennai', '₹65 L', '2BHK in gated community', Icons.domain),
      _PropertyItem('Independent House', 'Mumbai', '₹2.1 Cr', '4BHK sea-facing', Icons.house),
      _PropertyItem('Land Parcel', 'Pune', '₹45 L', 'Ready for construction', Icons.landscape),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Let parent handle bg or use themed
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(label: const Text('All'), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Land'), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('House'), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Flat'), onSelected: (_) {}),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: properties.length,
              itemBuilder: (_, i) {
                final p = properties[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(p.icon, color: AppColors.primary, size: 28),
                    ),
                    title: Text(
                      p.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.location, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(p.description, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(p.price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => context.push('/property-owner/property/$i'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/property-owner/add-property'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _PropertyItem {
  final String title;
  final String location;
  final String price;
  final String description;
  final IconData icon;

  _PropertyItem(this.title, this.location, this.price, this.description, this.icon);
}
