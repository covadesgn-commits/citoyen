import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/pme_providers.dart';

class PmeMapScreen extends ConsumerStatefulWidget {
  const PmeMapScreen({super.key});

  @override
  ConsumerState<PmeMapScreen> createState() => _PmeMapScreenState();
}

class _PmeMapScreenState extends ConsumerState<PmeMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isLoadingLocation = true);

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Le service de localisation est désactivé.')),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Les permissions de localisation sont refusées.')),
            );
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Les permissions de localisation sont définitivement refusées.')),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        _mapController.move(_currentPosition!, 14);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to real-time reports stream
    ref.listen<AsyncValue<List<Map<String, dynamic>>>>(
      pmeReportsStreamProvider,
      (previous, next) {
        if (next is AsyncData && previous is AsyncData) {
          final previousCount = previous?.valueOrNull?.length ?? 0;
          final nextCount = next.valueOrNull?.length ?? 0;
          if (nextCount > previousCount) {
             // Refresh map markers by invalidating the FutureProvider
             ref.invalidate(wasteReportsProvider);
             
             // Show notification
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text('Un nouveau signalement a été attribué à votre entreprise !'),
                 backgroundColor: AppColors.primary,
                 duration: Duration(seconds: 4),
               ),
             );
          }
        }
      },
    );

    final reportsAsync = ref.watch(wasteReportsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full Screen Map
          reportsAsync.when(
            data: (reports) {
              final markers = reports.map((report) {
                return Marker(
                  width: 45.0,
                  height: 45.0,
                  point: report.location,
                  child: GestureDetector(
                    onTap: () {
                      context.push(
                        '/dashboard-pme/carte/details',
                        extra: {
                          'citoyen': report.citizenId,
                          'location': '${report.location.latitude}, ${report.location.longitude}',
                          'image': report.photos.isNotEmpty ? report.photos.first : null,
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                );
              }).toList();

              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(9.5092, -13.7122),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.covades.app',
                  ),
                  const MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(9.5092, -13.7122),
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(child: Text('Erreur: $err')),
          ),

          // Floating Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    child: const Row(
                      children: [
                        Icon(Icons.map_rounded, color: Colors.black, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Carte des signalements',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(FontAwesomeIcons.bell, color: Colors.black, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              onPressed: _checkPermissionAndGetLocation,
              backgroundColor: Colors.white,
              child: _isLoadingLocation 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // Bottom Info Card (Floating)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: reportsAsync.maybeWhen(
              data: (reports) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Signalements à proximité',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${reports.length} collectes disponibles dans votre zone',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
