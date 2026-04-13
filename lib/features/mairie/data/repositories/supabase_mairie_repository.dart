import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final mairieRepositoryProvider = Provider<MairieRepository>((ref) {
  return MairieRepository(Supabase.instance.client);
});

class MairieRepository {
  final SupabaseClient _supabase;

  MairieRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getRecentReports() async {
    final response = await _supabase
        .from('citizen_reports')
        .select('id, category, location_address, status, priority, createdat')
        .order('createdat', ascending: false)
        .limit(8);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> getTotalReportsCount() async {
    final response = await _supabase.from('citizen_reports').select('id');
    return response.length;
  }

  Future<int> getPendingReportsCount() async {
    final response = await _supabase
        .from('citizen_reports')
        .select('id')
        .inFilter('status', ['recu', 'reçu', 'en attente', 'nouveau']);
    return response.length;
  }

  Future<int> getResolvedReportsCount() async {
    final response = await _supabase
        .from('citizen_reports')
        .select('id')
        .inFilter('status', ['collecte', 'collecté', 'traite', 'traité', 'resolu', 'résolu']);
    return response.length;
  }

  Future<List<Map<String, dynamic>>> getMunicipalServices() async {
    return [
      {
        'title': 'Validation des signalements',
        'description': 'Vérifier, prioriser et orienter les signalements vers les équipes terrain.',
        'icon': 'fact_check',
      },
      {
        'title': 'Coordination avec les PME',
        'description': 'Affecter les collectes aux partenaires et suivre leur exécution.',
        'icon': 'handshake',
      },
      {
        'title': 'Suivi des zones sensibles',
        'description': 'Identifier les quartiers avec un fort volume de déchets ou de plaintes.',
        'icon': 'map',
      },
      {
        'title': 'Communication citoyenne',
        'description': 'Notifier les habitants sur les opérations de nettoyage et campagnes locales.',
        'icon': 'campaign',
      },
    ];
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select('name, email, phone')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['name'] != null) {
        return {
          'name': response['name'],
          'email': response['email'] ?? user.email,
          'phone': response['phone'],
          'commune': user.userMetadata?['commune'],
          'role_label': 'Compte Mairie',
        };
      }
    } catch (_) {}

    final metadata = user.userMetadata;
    return {
      'name': metadata?['manager_name'] ?? metadata?['name'] ?? 'Responsable mairie',
      'email': user.email,
      'phone': metadata?['contact_phone'] ?? user.phone,
      'commune': metadata?['commune'] ?? 'Commune non renseignée',
      'role_label': 'Compte Mairie',
    };
  }
}
