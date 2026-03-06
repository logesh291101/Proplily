import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../theme/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Get in Touch',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'We provide property monitoring, management, legal, valuation, and real estate services across major Indian cities.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Card(
          //   elevation: 0,
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          //   child: Padding(
          //     padding: const EdgeInsets.all(20),
          //     child: Column(
          //       children: [
          //         ListTile(
          //           leading: CircleAvatar(
          //             backgroundColor: AppColors.primary.withOpacity(0.15),
          //             child: const Icon(Icons.email, color: AppColors.primary),
          //           ),
          //           title: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          //           subtitle: const Text('info@proplilly.com'),
          //           onTap: () => _launchUrl('mailto:info@proplilly.com'),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _launchUrl('mailto:info@proplilly.com'),
                  icon: const Icon(Icons.email),
                  label: const Text('Email Us'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _launchUrl('tel:+911234567890'),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Us'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Where to Find Us',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bangalore • Hyderabad • Chennai • Mumbai • Pune',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(18.5204, 76.8567), // Centered roughly between the cities
                initialZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.proplilly.app',
                ),
                MarkerLayer(
                  markers: [
                    _buildMarker(
                      context,
                      const LatLng(12.9716, 77.5946),
                      'Bangalore',
                    ),
                    _buildMarker(
                      context,
                      const LatLng(17.3850, 78.4867),
                      'Hyderabad',
                    ),
                    _buildMarker(
                      context,
                      const LatLng(13.0827, 80.2707),
                      'Chennai',
                    ),
                    _buildMarker(
                      context,
                      const LatLng(19.0760, 72.8777),
                      'Mumbai',
                    ),
                    _buildMarker(
                      context,
                      const LatLng(18.5204, 73.8567),
                      'Pune',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(BuildContext context, LatLng point, String label) {
    return Marker(
      point: point,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Our office in $label')),
          );
        },
        child: Column(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.primaryDark,
              size: 40,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
