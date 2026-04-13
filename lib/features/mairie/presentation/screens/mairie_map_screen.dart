import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';

class MairieMapScreen extends StatefulWidget {
  const MairieMapScreen({super.key});

  @override
  State<MairieMapScreen> createState() => _MairieMapScreenState();
}

class _MairieMapScreenState extends State<MairieMapScreen> {
  // Conakry roughly
  final LatLng _initialCenter = const LatLng(9.5350, -13.6773);
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _mockMarkers = [
    {
      'position': const LatLng(9.5400, -13.6700),
      'title': 'Marché Central',
      'severity': 'haute',
    },
    {
      'position': const LatLng(9.5300, -13.6800),
      'title': 'Carrefour Aéroport',
      'severity': 'moyenne',
    },
    {
      'position': const LatLng(9.5250, -13.6600),
      'title': 'Zone Est',
      'severity': 'faible',
    },
  ];

  void _showMarkerDetails(Map<String, dynamic> markerInfo) {
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
                      color: _getSeverityColor(markerInfo['severity']).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: _getSeverityColor(markerInfo['severity']),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          markerInfo['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Priorité ${_capitalize(markerInfo['severity'])}',
                          style: TextStyle(
                            color: _getSeverityColor(markerInfo['severity']),
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
                'Détails de la zone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Plusieurs signalements non traités ont été détectés dans cette zone au cours des dernières 48 heures. Une intervention rapide est recommandée.',
                style: TextStyle(
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
                  child: const Text(
                    'Planifier une intervention',
                    style: TextStyle(
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

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'haute':
        return AppColors.error;
      case 'moyenne':
        return Colors.orange;
      case 'faible':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.covades.mobile',
              ),
              MarkerLayer(
                markers: _mockMarkers.map((marker) {
                  return Marker(
                    point: marker['position'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showMarkerDetails(marker),
                      child: Icon(
                        Icons.location_on,
                        color: _getSeverityColor(marker['severity']),
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rechercher une zone...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(Icons.filter_list, color: AppColors.textPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
