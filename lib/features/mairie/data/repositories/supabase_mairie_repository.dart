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

  Future<List<Map<String, dynamic>>> getMapMarkers() async {
    // 1. Fetch active reports
    final reportsResponse = await _supabase
        .from('citizen_reports')
        .select('id, category, location_address, status, priority, location_coordinates_lat, location_coordinates_lng')
        .inFilter('status', ['reçu', 'acceptée', 'en_route', 'collectée']);

    // 2. Fetch PMEs
    final pmeResponse = await _supabase
        .from('users')
        .select('id, name, location_address, location_coordinates_lat, location_coordinates_lng, isactive, pme_info(businessname)')
        .eq('role', 'pme');

    // 3. Fetch ZTTs
    final zttResponse = await _supabase
        .from('users')
        .select('id, name, location_address, location_coordinates_lat, location_coordinates_lng, isactive, ztt_info(centername)')
        .eq('role', 'ztt');

    return [
      ...List<Map<String, dynamic>>.from(reportsResponse).map((r) => {...r, 'marker_type': 'report'}),
      ...List<Map<String, dynamic>>.from(pmeResponse).map((p) => {...p, 'marker_type': 'pme'}),
      ...List<Map<String, dynamic>>.from(zttResponse).map((z) => {...z, 'marker_type': 'ztt'}),
    ];
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select('*, mairie_info(*)')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        final mairieInfo = response['mairie_info'] as Map<String, dynamic>?;
        return {
          'name': response['name'] ?? 'Responsable mairie',
          'email': response['email'] ?? user.email,
          'phone': response['phone'] ?? '+224 ...',
          'mairie_name': mairieInfo?['mairiename'] ?? 'Mairie de Conakry',
          'address': response['location_address'] ?? 'Adresse non renseignée',
          'commune': response['location_commune'] ?? 'Conakry',
          'role_label': 'Compte Mairie',
        };
      }
    } catch (_) {}

    return {
      'name': 'Responsable mairie',
      'email': user.email,
      'phone': '+224 ...',
      'mairie_name': 'Mairie de Conakry',
      'address': 'Adresse non renseignée',
      'commune': 'Conakry',
      'role_label': 'Compte Mairie',
    };
  }
}
