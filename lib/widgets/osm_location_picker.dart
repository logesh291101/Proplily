import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';

class OSMLocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude) onLocationSelected;

  const OSMLocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
  });

  @override
  State<OSMLocationPicker> createState() => _OSMLocationPickerState();
}

class _OSMLocationPickerState extends State<OSMLocationPicker> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        _selectedLocation = LatLng(
          widget.initialLatitude!,
          widget.initialLongitude!,
        );
      } else {
        // Get current location
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _selectedLocation = const LatLng(12.9716, 77.5946); // Default to Bangalore
        } else {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.deniedForever || 
              permission == LocationPermission.denied) {
            _selectedLocation = const LatLng(12.9716, 77.5946); // Default
          } else {
            Position position = await Geolocator.getCurrentPosition();
            _selectedLocation = LatLng(position.latitude, position.longitude);
          }
        }
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedLocation = const LatLng(12.9716, 77.5946);
          _isLoading = false;
        });
      }
    }
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    widget.onLocationSelected(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _selectedLocation!,
        initialZoom: 15.0,
        onTap: _onTap,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.proplilly.app',
        ),
        MarkerLayer(
          markers: [
            if (_selectedLocation != null)
              Marker(
                point: _selectedLocation!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
