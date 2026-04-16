class FactoryModel {
  final String id;
  final String name;
  final String description;
  final List<String> specializedWasteTypes;
  final String address;
  final String phone;
  final String email;

  FactoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.specializedWasteTypes,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory FactoryModel.fromJson(Map<String, dynamic> json) {
    return FactoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      specializedWasteTypes: List<String>.from(json['specialized_waste_types'] ?? []),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
