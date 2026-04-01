import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() {
  test('Supabase Client instances correctly with env variables', () async {
    // Load env variables
    dotenv.testLoad(fileInput: File('.env').readAsStringSync());
    
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    expect(url, isNotNull);
    expect(anonKey, isNotNull);

    // Initialize Supabase
    await Supabase.initialize(
      url: url!,
      anonKey: anonKey!,
    );

    final client = Supabase.instance.client;
    expect(client, isNotNull);
    // A quick check that we can reach auth service
    expect(client.auth, isNotNull);
  });
}
