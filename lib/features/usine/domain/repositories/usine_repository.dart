import '../models/factory_product.dart';
import '../models/available_material.dart';

abstract class UsineRepository {
  Future<List<AvailableMaterial>> getAvailableMaterials();
  Future<void> buyMaterial({
    required String materialId,
    required String factoryId,
    required double amount,
  });
  Future<void> createProduct(FactoryProduct product);
  Future<List<FactoryProduct>> getFactoryProducts(String factoryId);
  Future<Map<String, dynamic>> getFactoryStats(String factoryId);
  Future<List<Map<String, dynamic>>> getFactoryOrders(String factoryId);
}
