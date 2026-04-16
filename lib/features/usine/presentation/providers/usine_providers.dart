import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/usine_repository_impl.dart';
import '../../domain/models/available_material.dart';
import '../../domain/models/factory_product.dart';
import '../../domain/repositories/usine_repository.dart';

final usineRepositoryProvider = Provider<UsineRepository>((ref) {
  return UsineRepositoryImpl(Supabase.instance.client);
});

final usineProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Non connecté');

  try {
    final response = await Supabase.instance.client
        .from('users')
        .select('*, factory_info(*)')
        .eq('id', user.id)
        .maybeSingle();
        
    if (response != null) return response;
    
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['factory_name'] ?? 'Usine sans nom',
      'location_address': user.userMetadata?['location_address'] ?? 'Non renseignée',
    };
  } catch (e) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['factory_name'] ?? 'Usine sans nom',
      'location_address': user.userMetadata?['location_address'] ?? 'Non renseignée',
    };
  }
});

final availableMaterialsProvider = FutureProvider<List<AvailableMaterial>>((ref) async {
  return ref.watch(usineRepositoryProvider).getAvailableMaterials();
});

final factoryProductsProvider = FutureProvider<List<FactoryProduct>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return ref.watch(usineRepositoryProvider).getFactoryProducts(user.id);
});

final usineStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return {'total_products': 0, 'total_purchases': 0};
  return ref.watch(usineRepositoryProvider).getFactoryStats(user.id);
});
