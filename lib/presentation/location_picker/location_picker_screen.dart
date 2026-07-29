import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';

/// Result returned by [LocationPickerScreen] via `Get.back(result: ...)`.
class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address = '',
  });
}

/// A full-screen map picker. The pin stays centered while the map pans
/// beneath it — wherever the pin lands is the picked point. Uses a native
/// Google map when [AppConfig.hasGoogleMaps] is set, otherwise free
/// OpenStreetMap tiles. The address is reverse-geocoded automatically.
class LocationPickerScreen extends StatefulWidget {
  /// Optional starting point (e.g. a previously-picked location).
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Fallback: geographic center of Pakistan, used before a fix is available.
  static const ll.LatLng _fallback = ll.LatLng(30.3753, 69.3451);

  final MapController _osmController = MapController();
  final Geocoding _geocoding = Geocoding();
  gmap.GoogleMapController? _googleController;

  late ll.LatLng _center;
  String _address = '';
  bool _resolving = false;
  bool _locating = true;
  Timer? _geocodeDebounce;

  @override
  void initState() {
    super.initState();
    _center = (widget.initialLatitude != null && widget.initialLongitude != null)
        ? ll.LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _fallback;
    // If we were given a starting point, resolve its address immediately.
    if (widget.initialLatitude != null) {
      _locating = false;
      _reverseGeocode(_center);
    } else {
      _goToCurrentLocation(initial: true);
    }
  }

  Future<void> _goToCurrentLocation({bool initial = false}) async {
    if (mounted) setState(() => _locating = true);
    try {
      final position = await _determinePosition();
      final target = ll.LatLng(position.latitude, position.longitude);
      _moveTo(target);
    } catch (_) {
      if (!initial) {
        Get.snackbar('Location', 'Could not get your current location.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  void _moveTo(ll.LatLng target) {
    setState(() => _center = target);
    if (AppConfig.hasGoogleMaps) {
      _googleController?.animateCamera(
        gmap.CameraUpdate.newLatLng(gmap.LatLng(target.latitude, target.longitude)),
      );
    } else {
      _osmController.move(target, _osmController.camera.zoom);
    }
    _reverseGeocode(target);
  }

  /// Debounced so we don't hammer the geocoder while the map is still moving.
  void _onCenterChanged(ll.LatLng center) {
    _center = center;
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 600), () {
      _reverseGeocode(center);
    });
  }

  Future<void> _reverseGeocode(ll.LatLng point) async {
    if (mounted) setState(() => _resolving = true);
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(point.latitude, point.longitude);
      final address = placemarks.isNotEmpty ? _formatPlacemark(placemarks.first) : '';
      if (mounted) setState(() => _address = address);
    } catch (_) {
      // Geocoding can fail (no network / no result). Keep the last address.
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  String _formatPlacemark(Placemark p) {
    final parts = <String?>[
      p.name,
      p.subLocality,
      p.locality,
      p.administrativeArea,
      p.country,
    ];
    final seen = <String>{};
    final cleaned = <String>[];
    for (final part in parts) {
      final value = part?.trim();
      if (value == null || value.isEmpty) continue;
      if (seen.add(value)) cleaned.add(value);
    }
    return cleaned.join(', ');
  }

  void _confirm() {
    Get.back<PickedLocation>(
      result: PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address,
      ),
    );
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _googleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: Text('Pick location', style: AppTextStyles.h2()),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap()),
          // Center pin overlay — nudged up so its tip marks the exact center.
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, size: 48, color: AppColors.elaraBlue),
            ),
          ),
          Positioned(
            right: AppSpacing.lg,
            bottom: 180,
            child: FloatingActionButton(
              heroTag: 'my-location',
              backgroundColor: AppColors.snow,
              foregroundColor: AppColors.elaraBlue,
              onPressed: _locating ? null : () => _goToCurrentLocation(),
              child: _locating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.elaraBlue),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: _AddressCard(
              address: _address,
              latitude: _center.latitude,
              longitude: _center.longitude,
              resolving: _resolving,
              onConfirm: _confirm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (AppConfig.hasGoogleMaps) {
      return gmap.GoogleMap(
        initialCameraPosition: gmap.CameraPosition(
          target: gmap.LatLng(_center.latitude, _center.longitude),
          zoom: 15,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (c) => _googleController = c,
        onCameraMove: (pos) => _center = ll.LatLng(pos.target.latitude, pos.target.longitude),
        onCameraIdle: () => _onCenterChanged(_center),
      );
    }

    return FlutterMap(
      mapController: _osmController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 15,
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture) _center = camera.center;
        },
        onMapEvent: (event) {
          if (event is MapEventMoveEnd ||
              event is MapEventFlingAnimationEnd ||
              event is MapEventDoubleTapZoomEnd) {
            _onCenterChanged(_osmController.camera.center);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.elarawave.elarawave',
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String address;
  final double latitude;
  final double longitude;
  final bool resolving;
  final VoidCallback onConfirm;

  const _AddressCard({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.resolving,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_outlined, size: 18, color: AppColors.elaraBlue),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: resolving && address.isEmpty
                    ? Text('Finding address…', style: AppTextStyles.body(color: AppColors.inkMuted))
                    : Text(
                        address.isEmpty ? 'Move the map to place the pin' : address,
                        style: AppTextStyles.body(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (resolving)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm, top: 2),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.elaraBlue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
            style: AppTextStyles.tabular(AppTextStyles.caption(color: AppColors.inkMuted)),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Use this location', onPressed: onConfirm),
        ],
      ),
    );
  }
}
