import 'package:latlong2/latlong.dart';

class WasteTypeSelection {
  final String type;
  final double weight; // in kg

  WasteTypeSelection({
    required this.type,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'weight': weight,
  };

  factory WasteTypeSelection.fromJson(Map<String, dynamic> json) => WasteTypeSelection(
    type: json['type'],
    weight: (json['weight'] as num).toDouble(),
  );
}

class ZttReport {
  final String id;
  final DateTime date;
  final double totalWeight;
  final List<WasteTypeSelection> selections;
  final String locationName;
  final LatLng location;
  final String factoryId;
  final String factoryName;
  final String zttId;

  ZttReport({
    required this.id,
    required this.date,
    required this.totalWeight,
    required this.selections,
    required this.locationName,
    required this.location,
    required this.factoryId,
    required this.factoryName,
    required this.zttId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'total_weight': totalWeight,
    'selections': selections.map((s) => s.toJson()).toList(),
    'location_name': locationName,
    'latitude': location.latitude,
    'longitude': location.longitude,
    'factory_id': factoryId,
    'factory_name': factoryName,
    'ztt_id': zttId,
  };
}
