class AvailableMaterial {
  final String id;
  final String material;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String zttId;
  final Map<String, dynamic>? zttInfo;
  final String status;

  AvailableMaterial({
    required this.id,
    required this.material,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.zttId,
    this.zttInfo,
    required this.status,
  });

  factory AvailableMaterial.fromJson(Map<String, dynamic> json) {
    return AvailableMaterial(
      id: json['id'] as String,
      material: json['material'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      pricePerUnit: (json['priceperunit'] as num).toDouble(),
      zttId: json['ztt_id'] as String,
      zttInfo: json['users'], // Supabase join returns data under 'users' key
      status: json['status'] as String,
    );
  }
}
