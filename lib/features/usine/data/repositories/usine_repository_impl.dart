import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/factory_product.dart';
import '../../domain/models/available_material.dart';
import '../../domain/repositories/usine_repository.dart';

class UsineRepositoryImpl implements UsineRepository {
  final SupabaseClient _supabase;

  UsineRepositoryImpl(this._supabase);

  @override
  Future<List<AvailableMaterial>> getAvailableMaterials() async {
    final response = await _supabase
        .from('materials_available')
        .select('*, users!materials_available_ztt_id_fkey(name, location_address)')
        .eq('status', 'disponible');
    
    return (response as List).map((json) => AvailableMaterial.fromJson(json)).toList();
  }

  @override
  Future<void> buyMaterial({
    required String materialId,
    required String factoryId,
    required double amount,
  }) async {
    // 1. Update material status
    await _supabase
        .from('materials_available')
        .update({
          'status': 'reserve',
          'reservedby_factoryid': factoryId,
          'reservedby_reserveddate': DateTime.now().toIso8601String(),
        })
        .eq('id', materialId);

    // 2. Create a payment record
    await _supabase
        .from('payments')
        .insert({
          'user_id': factoryId,
          'type': 'achat_matiere',
          'amount': amount,
          'status': 'completed',
          'purpose': 'Achat de matière première',
          'relatedentity_type': 'materials_available',
          'relatedentity_id': materialId,
        });
  }

  @override
  Future<void> createProduct(FactoryProduct product) async {
    await _supabase.from('factory_products').insert(product.toJson());
  }

  @override
  Future<List<FactoryProduct>> getFactoryProducts(String factoryId) async {
    final response = await _supabase
        .from('factory_products')
        .select()
        .eq('factory_id', factoryId)
        .order('createdat', ascending: false);
    
    return (response as List).map((json) => FactoryProduct.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> getFactoryStats(String factoryId) async {
    try {
      final productsResponse = await _supabase
          .from('factory_products')
          .select('id')
          .eq('factory_id', factoryId);

      final purchasesResponse = await _supabase
          .from('materials_available')
          .select('id')
          .eq('reservedby_factoryid', factoryId);

      return {
        'total_products': (productsResponse as List).length,
        'total_purchases': (purchasesResponse as List).length,
        'available_materials_count': 0, 
      };
    } catch (e) {
      return {
        'total_products': 0,
        'total_purchases': 0,
        'available_materials_count': 0,
      };
    }
  }
}
