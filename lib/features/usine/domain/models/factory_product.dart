class FactoryProduct {
  final String id;
  final String factoryId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imageUrl;
  final DateTime? createdat;

  FactoryProduct({
    required this.id,
    required this.factoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
    this.createdat,
  });

  factory FactoryProduct.fromJson(Map<String, dynamic> json) {
    return FactoryProduct(
      id: json['id'] as String,
      factoryId: json['factory_id'] as String,
      name: json['name'] as String,
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      category: json['category'] as String,
      imageUrl: (json['images'] as List?)?.isNotEmpty == true ? (json['images'] as List).first : null,
      createdat: json['createdat'] != null ? DateTime.parse(json['createdat']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'factory_id': factoryId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }
}
