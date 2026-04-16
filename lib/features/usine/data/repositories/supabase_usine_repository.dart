import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final usineRepositoryProvider = Provider<UsineRepository>((ref) {
  return UsineRepository(Supabase.instance.client);
});

class UsineRepository {
  final SupabaseClient _supabase;

  UsineRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getRecentReports() async {
    final response = await _supabase
        .from('citizen_reports')
        .select('id, category, size, status, priority, createdat')
        .order('createdat', ascending: false)
        .limit(8);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> getProcessedReportsCount() async {
    final response = await _supabase
        .from('citizen_reports')
        .select('id')
        .inFilter('status', ['collecte', 'collecté', 'traite', 'traité', 'resolu', 'résolu']);
    return response.length;
  }

  Future<int> getPendingReportsCount() async {
    final response = await _supabase
        .from('citizen_reports')
        .select('id')
        .inFilter('status', ['recu', 'reçu', 'en attente', 'nouveau']);
    return response.length;
  }

  Future<List<Map<String, dynamic>>> getAcceptedMaterials() async {
    final materials = _supabase.auth.currentUser?.userMetadata?['materials_accepted']?.toString();
    final values = materials == null || materials.isEmpty
        ? <String>['Plastique', 'Papier', 'Métal']
        : materials.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();

    return values.map((item) {
      return {
        'title': item,
        'description': 'Flux traité par l\'usine pour transformation ou recyclage.',
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata;
    return {
      'name': metadata?['factory_name'] ?? metadata?['name'] ?? 'Usine',
      'email': user.email,
      'phone': metadata?['contact_phone'] ?? user.phone,
      'manager': metadata?['manager_name'] ?? 'Responsable non renseigné',
      'materials': metadata?['materials_accepted'] ?? 'Non renseigné',
    };
  }
}
