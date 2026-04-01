import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<User?> signUp({required String email, required String password, Map<String, dynamic>? metadata}) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
    return response.user;
  }

  @override
  Future<User?> signIn({required String email, required String password}) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    await _supabase.auth.signInWithOAuth(provider);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
