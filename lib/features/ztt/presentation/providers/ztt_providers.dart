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
        .select('*, ztt_info(*)')
        .eq('id', user.id)
        .maybeSingle();
        
    if (response != null) return response;
    
    // Fallback
    return {
      'id': user.id,
      'name': 'Zone de Transit',
    };
  } catch (e) {
    return {'id': user.id, 'name': 'Zone de Transit'};
  }
});

final zttStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Non connecté');
  
  final response = await Supabase.instance.client
      .from('ztt_entries')
      .select('id, receivedweight')
      .eq('ztt_id', user.id);

  double totalWeight = 0;
  for (var entry in response) {
    totalWeight += (entry['receivedweight'] as num?)?.toDouble() ?? 0.0;
  }

  return {
    'totalWeight': totalWeight,
    'totalSorts': response.length,
  };
});
