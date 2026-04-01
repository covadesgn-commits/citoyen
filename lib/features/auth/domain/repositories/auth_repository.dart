import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User?> signUp({required String email, required String password, Map<String, dynamic>? metadata});
  Future<User?> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> signInWithOAuth(OAuthProvider provider);
  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;
}
