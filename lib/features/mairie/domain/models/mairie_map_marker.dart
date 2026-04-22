import 'package:latlong2/latlong.dart';

enum MarkerType { report, pme, ztt }

class MairieMapMarker {
  final String id;
  final String title;
  final String? description;
  final LatLng position;
  final MarkerType type;
  final String? severity; // Only for reports
  final String? status;   // For reports or entities

  MairieMapMarker({
    required this.id,
    required this.title,
    this.description,
    required this.position,
    required this.type,
    this.severity,
    this.status,
  });

  factory MairieMapMarker.fromReport(Map<String, dynamic> json) {
    return MairieMapMarker(
      id: json['id'],
      title: json['category'] ?? 'Signalement',
      description: json['location_address'],
      position: LatLng(
        (json['location_coordinates_lat'] as num?)?.toDouble() ?? 0.0,
        (json['location_coordinates_lng'] as num?)?.toDouble() ?? 0.0,
      ),
      type: MarkerType.report,
      severity: json['priority'],
      status: json['status'],
    );
  }

  factory MairieMapMarker.fromEntity(Map<String, dynamic> json, MarkerType type) {
    final name = type == MarkerType.pme 
        ? (json['pme_info']?['businessname'] ?? json['name'] ?? 'PME')
        : (json['ztt_info']?['centername'] ?? json['name'] ?? 'ZTT');
        
    return MairieMapMarker(
      id: json['id'],
      title: name,
      description: json['location_address'],
      position: LatLng(
        (json['location_coordinates_lat'] as num?)?.toDouble() ?? 0.0,
        (json['location_coordinates_lng'] as num?)?.toDouble() ?? 0.0,
      ),
      type: type,
      status: json['isactive'] == true ? 'actif' : 'inactif',
    );
  }
}
