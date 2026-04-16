import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/models/ztt_report.dart';
import '../../domain/models/factory_model.dart';
import '../../domain/repositories/ztt_repository.dart';

class ZttRepositoryImpl implements IZttRepository {
  final SupabaseClient _client;

  ZttRepositoryImpl(this._client);

  @override
  Future<List<ZttReport>> getHistory() async {
    try {
      final response = await _client
          .from('tri')
          .select('''
            *,
            usines:usine_id (
              name
            ),
            details:details_tri (*)
          ''')
          .order('date_tri', ascending: false);
      
      return (response as List).map((json) {
        final List<dynamic> detailsJson = json['details'] ?? [];
        final selections = detailsJson.map((d) => WasteTypeSelection(
          type: d['type_dechet'] ?? 'Inconnu',
          weight: (d['poids'] as num?)?.toDouble() ?? 0.0,
        )).toList();

        return ZttReport(
          id: json['id'].toString(),
          date: DateTime.tryParse(json['date_tri']?.toString() ?? '') ?? DateTime.now(),
          totalWeight: (json['poids_total'] as num?)?.toDouble() ?? 0.0,
          selections: selections,
          locationName: 'Zone de Transit',
          location: const LatLng(0, 0),
          factoryId: json['usine_id']?.toString() ?? '',
          factoryName: json['usines']?['name'] ?? 'Usine inconnue',
          zttId: json['ztt_id']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      return []; 
    }
  }

  @override
  Future<void> submitSortingReport({
    required List<WasteTypeSelection> selections,
    required String factoryId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Non connecté');

    final totalWeight = selections.fold<double>(0, (sum, s) => sum + s.weight);

    final tri = await _client.from('tri').insert({
      'ztt_id': user.id,
      'usine_id': factoryId,
      'poids_total': totalWeight,
      'date_tri': DateTime.now().toIso8601String(),
    }).select().single();

    for (var s in selections) {
      await _client.from('details_tri').insert({
        'tri_id': tri['id'],
        'type_dechet': s.type,
        'poids': s.weight,
      });
    }
  }

  @override
  Future<List<FactoryModel>> getFactories() async {
    try {
      final response = await _client
          .from('users')
          .select('id, name, email, phone, location_address, factory_info(industryType, materialsAccepted)')
          .eq('role', 'usine');
          
      return (response as List).map((json) => FactoryModel(
        id: json['id'],
        name: json['name'] ?? 'Usine sans nom',
        description: json['factory_info']?['industryType'] ?? '',
        specializedWasteTypes: List<String>.from(json['factory_info']?['materialsAccepted'] ?? []),
        address: json['location_address'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
      )).toList();
    } catch (e) {
      return []; // Return empty gracefully
    }
  }
}
