import 'package:dio/dio.dart';
import '../models/recommendation_model.dart';

class RecommendationService {
  final Dio _dio;

  RecommendationService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000', // Adjust to your server URL
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<List<RecommendationModel>> fetchRecommendations(String studentId) async {
    try {
      final response = await _dio.get('/api/recommendations/$studentId');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => RecommendationModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}