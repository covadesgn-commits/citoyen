import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final citoyenRepositoryProvider = Provider<CitoyenRepository>((ref) {
  return CitoyenRepository(Supabase.instance.client);
});

class CitoyenRepository {
  final SupabaseClient _supabase;

  CitoyenRepository(this._supabase);

  // ----- PME Subscriptions -----

  Future<List<Map<String, dynamic>>> getAvailablePMEs() async {
    // Fetch users with role 'pme' joined with 'pme_info'
    final response = await _supabase
        .from('users')
        .select('''
          id, 
          name, 
          location_address, 
          pme_info(businessname, ifu, rccm)
        ''')
        .eq('role', 'pme')
        .eq('isactive', true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> subscribeToPME(String pmeId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Utilisateur non connecté');

    await _supabase.from('citizen_subscriptions').insert({
      'citizen_id': userId,
      'pme_id': pmeId,
      'status': 'active',
    });
  }

  // ----- Waste Reporting -----

  Future<void> reportWaste({
    required String category,
    required String size,
    required String description,
    required double lat,
    required double lng,
    required String address,
    required File imageFile,
    String priority = 'moyenne',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non connecté');

      // 1. Upload the image to Supabase Storage
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'reports/$userId/$fileName';

      try {
        await _supabase.storage.from('reports_images').upload(filePath, imageFile);
      } catch (storageError) {
        throw Exception('Échec de l\'envoi de l\'image : $storageError (vérifiez si le bucket "reports_images" existe)');
      }

      final photoUrl = _supabase.storage.from('reports_images').getPublicUrl(filePath);

      // 2. Insert the report into the database
      // Ensure size matches DB ENUM EXACTLY (très_grand with accent)
      final dbSize = size.toLowerCase(); 

      try {
        await _supabase.from('citizen_reports').insert({
          'citizen_id': userId,
          'category': category.toLowerCase(),
          'size': dbSize,
          'description': description,
          'photos': [photoUrl],
          'location_coordinates_lat': lat,
          'location_coordinates_lng': lng,
          'location_address': address,
          'priority': priority,
          'status': 'reçu',
        });
      } catch (dbError) {
        throw Exception('Erreur d\'enregistrement en base : $dbError');
      }
    } catch (e) {
      // Re-throw with original context if it's already an Exception
      rethrow;
    }
  }

  // ----- Recent Actions -----

  Future<List<Map<String, dynamic>>> getRecentReports() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Utilisateur non connecté');

    final response = await _supabase
        .from('citizen_reports')
        .select()
        .eq('citizen_id', userId)
        .order('createdat', ascending: false)
        .limit(5);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getRecentSubscriptions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Utilisateur non connecté');

    final response = await _supabase
        .from('citizen_subscriptions')
        .select('''
          id, 
          status, 
          createdat, 
          pme_id, 
          users!pme_id(name)
        ''')
        .eq('citizen_id', userId)
        .order('createdat', ascending: false)
        .limit(5);

    return List<Map<String, dynamic>>.from(response);
  }

  // --- Marketplace ---

  Future<List<Map<String, dynamic>>> getProducts() async {
    return [
      {
        'category': 'Jardinage',
        'title': 'Engrais Naturel Bio',
        'price': '85 000 GNF',
        'image': 'asset/engrais_bio.jpeg',
      },
      {
        'category': 'Décoration',
        'title': 'Panier Écologique',
        'price': '120 000 GNF',
        'image': "asset/panier_ecologique.jpeg",
      },
      {
        'category': 'Logistique',
        'title': 'Casiers de Rangement',
        'price': '250 000 GNF',
        'image': 'asset/plastic_crates.jpeg',
      },
      {
        'category': 'Maison',
        'title': 'Bassines Recyclées',
        'price': '45 000 GNF',
        'image': 'asset/washtub.jpeg',
      },
      {
        'category': 'Construction',
        'title': 'Pavés Écologiques',
        'price': '500 000 GNF',
        'image': 'asset/plastic_industry.jpeg',
      },
      {
        'category': 'Agriculture',
        'title': 'Compost Organique',
        'price': '95 000 GNF',
        'image': 'asset/harvesting_compost.jpeg',
      },
      {
        'category': 'Recyclage',
        'title': 'Bouchons Plastiques',
        'price': '15 000 GNF',
        'image': 'asset/plastic_caps.jpeg',
      },
      {
        'category': 'Jardinage',
        'title': 'Seaux en Métal Mini',
        'price': '65 000 GNF',
        'image': 'asset/mini_metal_buckets.jpeg',
      },
      {
        'category': 'Décoration',
        'title': 'Vase en Verre Artisanal',
        'price': '110 000 GNF',
        'image': 'asset/img1.jpeg',
      },
      {
        'category': 'Maison',
        'title': 'Boîtes de Rangement',
        'price': '75 000 GNF',
        'image': 'asset/img2.jpeg',
      },
    ];
  }

  // --- Profile Stats ---

  Future<int> getReportCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('citizen_reports')
        .select('id')
        .eq('citizen_id', userId);
    
    return response.length;
  }

  Future<String?> getActivePMESubscription() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('citizen_subscriptions')
        .select('users!pme_id(name)')
        .eq('citizen_id', userId)
        .eq('status', 'active')
        .maybeSingle();
    
    if (response == null) return null;
    return response['users']?['name'];
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // 1. Try to get from public.users table
    try {
      final response = await _supabase
          .from('users')
          .select('name, email, phone')
          .eq('id', user.id)
          .maybeSingle();
      
      if (response != null && response['name'] != null) {
        return response;
      }
    } catch (_) {
      // Table might not exist or user not in it
    }

    // 2. Fallback to auth metadata
    final metadata = user.userMetadata;
    if (metadata != null) {
      return {
        'name': metadata['full_name'] ?? metadata['first_name'] ?? metadata['name'],
        'email': user.email,
        'phone': metadata['contact_phone'] ?? user.phone,
      };
    }
    
    return null;
  }
}
