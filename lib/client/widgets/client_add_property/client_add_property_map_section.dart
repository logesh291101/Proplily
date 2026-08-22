import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';

/// Interactive map card with GPS, zoom controls, and lat/lng fields.
class AddPropertyMapSection extends StatefulWidget {
  const AddPropertyMapSection({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.onLocationChanged,
  });

  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final VoidCallback? onLocationChanged;

  @override
  State<AddPropertyMapSection> createState() => _AddPropertyMapSectionState();
}

class _AddPropertyMapSectionState extends State<AddPropertyMapSection> {
  static const LatLng _defaultCenter = LatLng(20.5937, 78.9629);

  final MapController _mapController = MapController();
  LatLng _center = _defaultCenter;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _syncFromControllers();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _syncFromControllers() {
    final lat = double.tryParse(widget.latitudeController.text.trim());
    final lng = double.tryParse(widget.longitudeController.text.trim());
    if (lat != null && lng != null) {
      _center = LatLng(lat, lng);
    }
  }

  void _updateCoordinates(LatLng point) {
    widget.latitudeController.text = point.latitude.toStringAsFixed(6);
    widget.longitudeController.text = point.longitude.toStringAsFixed(6);
    setState(() => _center = point);
    _mapController.move(point, _mapController.camera.zoom);
    widget.onLocationChanged?.call();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to use GPS.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      _updateCoordinates(LatLng(position.latitude, position.longitude));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch your location. Try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _zoomIn() {
    final zoom = (_mapController.camera.zoom + 1).clamp(3.0, 18.0);
    _mapController.move(_center, zoom);
  }

  void _zoomOut() {
    final zoom = (_mapController.camera.zoom - 1).clamp(3.0, 18.0);
    _mapController.move(_center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: PremiumDecorations.iconTile(AppColors.primary),
              child: const Icon(
                Icons.map_outlined,
                size: 20,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Location (Map Picker) *',
                style: theme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _locating ? null : _useCurrentLocation,
            icon: _locating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded, size: 20),
            label: Text(_locating ? 'Locating...' : 'Use Current Location'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: AppColors.primaryLight.withValues(alpha: 0.7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
              ),
              boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 13,
                    onTap: (_, point) => _updateCoordinates(point),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.proplilly.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    children: [
                      _MapZoomButton(icon: Icons.add, onTap: _zoomIn),
                      const SizedBox(height: 8),
                      _MapZoomButton(icon: Icons.remove, onTap: _zoomOut),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ClientReferralPremiumField(
                controller: widget.latitudeController,
                label: 'Latitude',
                hint: '12.971600',
                icon: Icons.explore_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: FormValidators.latitude,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClientReferralPremiumField(
                controller: widget.longitudeController,
                label: 'Longitude',
                hint: '77.594600',
                icon: Icons.explore_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: FormValidators.longitude,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 3,
      shadowColor: AppColors.primaryDark.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.primaryDark, size: 22),
        ),
      ),
    );
  }
}

