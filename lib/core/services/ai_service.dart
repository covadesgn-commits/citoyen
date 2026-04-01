import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;

final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  final Dio _dio = Dio();
  final String _baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  Future<Map<String, dynamic>> analyzeWasteImage(File imageFile) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) throw Exception('Utilisateur non connecté');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: 'waste_image.jpg'),
      });

      final response = await _dio.post(
        '$_baseUrl/api/ai/analyze-image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur d\'analyse IA');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erreur de connexion au serveur IA';
      throw Exception(message);
    } catch (e) {
      throw Exception('Erreur lors de l\'analyse de l\'image : $e');
    }
  }
}
