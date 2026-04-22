import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/mairie_providers.dart';
import '../../domain/models/mairie_map_marker.dart';

class MairieMapScreen extends ConsumerStatefulWidget {
  const MairieMapScreen({super.key});

  @override
  ConsumerState<MairieMapScreen> createState() => _MairieMapScreenState();
}

class _MairieMapScreenState extends ConsumerState<MairieMapScreen> {
  final LatLng _defaultCenter = const LatLng(9.5350, -13.6773); // Conakry
  final MapController _mapController = MapController();
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_currentPosition!, 13.0);
        }
      }
    } catch (_) {}
  }

  void _showMarkerDetails(MairieMapMarker marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getMarkerColor(marker).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getMarkerIcon(marker.type),
                      color: _getMarkerColor(marker),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTypeLabel(marker),
                          style: TextStyle(
                            color: _getMarkerColor(marker),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Détails',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                marker.description ?? 'Aucune description disponible pour cet emplacement.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    marker.type == MarkerType.report ? 'Traiter le signalement' : 'Voir les détails',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Color _getMarkerColor(MairieMapMarker marker) {
    if (marker.type == MarkerType.report) {
      switch (marker.severity?.toLowerCase()) {
        case 'haute':
          return AppColors.error;
        case 'moyenne':
          return Colors.orange;
        case 'faible':
          return AppColors.success;
        default:
          return AppColors.primary;
      }
    } else if (marker.type == MarkerType.pme) {
      return Colors.blue;
    } else {
      return Colors.purple;
    }
  }

  IconData _getMarkerIcon(MarkerType type) {
    switch (type) {
      case MarkerType.report:
        return Icons.warning_amber_rounded;
      case MarkerType.pme:
        return Icons.business_rounded;
      case MarkerType.ztt:
        return Icons.warehouse_rounded;
    }
  }

  String _getTypeLabel(MairieMapMarker marker) {
    switch (marker.type) {
      case MarkerType.report:
        return 'Signalement (${marker.severity ?? 'Normal'})';
      case MarkerType.pme:
        return 'Entreprise PME';
      case MarkerType.ztt:
        return 'Centre ZTT';
    }
  }

  @override
  Widget build(BuildContext context) {
    final markersAsync = ref.watch(mapMarkersProvider);

    return Scaffold(
      body: Stack(
        children: [
          markersAsync.when(
            data: (markers) => FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? _defaultCenter,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.covades.mobile',
                ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: markers.map((marker) {
                    return Marker(
                      point: marker.position,
                      width: 45,
                      height: 45,
                      child: GestureDetector(
                        onTap: () => _showMarkerDetails(marker),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getMarkerColor(marker).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getMarkerIcon(marker.type),
                            color: _getMarkerColor(marker),
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Rechercher une zone...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location, color: AppColors.primary),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
