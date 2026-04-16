import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  /// Maps a technical error to a user-friendly message.
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return _handleAuthException(error);
    }
    
    if (error is PostgrestException) {
      return _handlePostgrestException(error);
    }

    final errorString = error.toString().toLowerCase();

    // Specific database constraint mappings
    if (errorString.contains('users_phone_key') || 
        errorString.contains('duplicate key value violates unique constraint "users_phone_key"')) {
      return 'Ce numéro de téléphone est déjà utilisé par un autre compte.';
    }

    if (errorString.contains('users_email_key') || 
        errorString.contains('duplicate key value violates unique constraint "users_email_key"')) {
      return 'Cette adresse email est déjà utilisée.';
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Problème de connexion internet. Veuillez réessayer.';
    }

    if (errorString.contains('timeout')) {
      return 'Le délai d\'attente est dépassé. Veuillez réessayer.';
    }

    return 'Une erreur inattendue est survenue. Veuillez réessayer.';
  }

  static String _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') || 
        message.contains('invalid email or password')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (message.contains('email not confirmed')) {
      return 'Veuillez confirmer votre adresse email avant de vous connecter.';
    }

    if (message.contains('already registered') || 
        message.contains('user already exists')) {
      return 'Un compte avec cet email existe déjà.';
    }

    if (message.contains('password should be') || 
        message.contains('password is too short')) {
      return 'Le mot de passe est trop court (min. 6 caractères).';
    }

    if (message.contains('users_phone_key')) {
      return 'Ce numéro de téléphone est déjà utilisé.';
    }

    return e.message; // Return original if not specifically mapped
  }

  static String _handlePostgrestException(PostgrestException e) {
    final message = e.message.toLowerCase();

    if (message.contains('users_phone_key')) {
      return 'Ce numéro de téléphone est déjà utilisé.';
    }

    return 'Erreur de base de données : ${e.message}';
  }
}
