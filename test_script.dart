import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://pjdgpkxccokvgqopibml.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqZGdwa3hjY29rdmdxb3BpYm1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDU1NDYsImV4cCI6MjA4ODkyMTU0Nn0.2hVSKwsUIOcV_kzEpyOGpI-lvyzrr4RYElc-BB-x4So';
  final client = SupabaseClient(supabaseUrl, supabaseKey);

  final timestamp = DateTime.now().millisecondsSinceEpoch;

  final profiles = [
    {
      'role': 'citoyen',
      'email': 'citoyen_$timestamp@test.com',
      'password': 'password123',
      'data': {
        'role': 'citoyen',
        'first_name': 'Jean',
        'last_name': 'Dupont',
        'contact_phone': '101$timestamp',
        'location_address': 'Rue du Citoyen',
      }
    },
    {
      'role': 'pme',
      'email': 'pme_$timestamp@test.com',
      'password': 'password123',
      'data': {
        'role': 'pme',
        'business_name': 'Super PME',
        'ifu': 'IFU123456',
        'rccm': 'RCCM-789',
        'contact_phone': '102$timestamp',
        'location_address': 'Avenue PME',
      }
    },
    {
      'role': 'ztt',
      'email': 'ztt_$timestamp@test.com',
      'password': 'password123',
      'data': {
        'role': 'ztt',
        'center_name': 'Centre ZTT Nord',
        'contact_phone': '103$timestamp',
        'location_address': 'Zone Industrielle',
      }
    },
    {
      'role': 'usine',
      'email': 'usine_$timestamp@test.com',
      'password': 'password123',
      'data': {
        'role': 'usine',
        'factory_name': 'Usine Recyclage SA',
        'contact_phone': '104$timestamp',
        'location_address': 'Route de l Usine',
      }
    },
    {
      'role': 'mairie',
      'email': 'mairie_$timestamp@test.com',
      'password': 'password123',
      'data': {
        'role': 'mairie',
        'commune': 'Commune Centrale',
        'contact_phone': '105$timestamp',
      }
    }
  ];

  for (var profile in profiles) {
    print('==============================');
    print('Testing Role: ${profile['role']}');
    try {
      final response = await client.auth.signUp(
        email: profile['email'] as String,
        password: profile['password'] as String,
        data: profile['data'] as Map<String, dynamic>,
      );
      print('✅ SUCCESS - User ID: ${response.user?.id}');
    } catch (e) {
      print('❌ ERROR - $e');
    }
    await Future.delayed(Duration(seconds: 1));
  }
}
