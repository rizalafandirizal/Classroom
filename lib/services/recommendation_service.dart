import 'package:dio/dio.dart';
import '../models/material_model.dart';

class RecommendationService {
  final Dio _dio;

  RecommendationService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://10.0.2.2:8000', // For Android emulator
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<List<MaterialModel>> fetchRecommendations(int userId) async {
    try {
      final response = await _dio.get('/api/recommendations', queryParameters: {'user_id': userId});

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['recommendations'] as List<dynamic>;
        return data.map((json) => MaterialModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}