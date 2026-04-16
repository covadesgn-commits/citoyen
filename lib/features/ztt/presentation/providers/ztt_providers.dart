import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/ztt_report.dart';
import '../../domain/models/factory_model.dart';
import '../../data/repositories/ztt_repository_impl.dart';

final zttRepositoryProvider = Provider((ref) {
  return ZttRepositoryImpl(Supabase.instance.client);
});

final zttHistoryProvider = FutureProvider<List<ZttReport>>((ref) async {
  return ref.watch(zttRepositoryProvider).getHistory();
});

final zttFactoriesProvider = FutureProvider<List<FactoryModel>>((ref) async {
  return ref.watch(zttRepositoryProvider).getFactories();
});

final zttProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Non connecté');

  try {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
        
    if (response != null) return response;
    
    // Fallback to Auth metadata if user table row is missing
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['center_name'] ?? user.userMetadata?['full_name'] ?? 'Utilisateur ZTT',
      'phone': user.userMetadata?['contact_phone'] ?? 'Non renseigné',
      'location_address': user.userMetadata?['location_address'] ?? 'Non renseignée',
    };
  } catch (e) {
    // If table doesn't exist or other DB error, still try to return metadata
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['center_name'] ?? user.userMetadata?['full_name'] ?? 'Utilisateur ZTT',
      'phone': user.userMetadata?['contact_phone'] ?? 'Non renseigné',
      'location_address': user.userMetadata?['location_address'] ?? 'Non renseignée',
    };
  }
});

final zttStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Non connecté');
  
  final response = await Supabase.instance.client
      .from('tri')
      .select('id, poids_total')
      .eq('ztt_id', user.id)
      .catchError((e) => <dynamic>[]);

  if (response is! List || response.isEmpty) {
    return {
      'totalWeight': 0.0,
      'totalSorts': 0,
    };
  }

  double totalWeight = 0;
  for (var tri in response) {
    totalWeight += (tri['poids_total'] as num?)?.toDouble() ?? 0.0;
  }

  return {
    'totalWeight': totalWeight,
    'totalSorts': response.length,
  };
});
