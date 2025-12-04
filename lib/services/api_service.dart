import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // Adjust this to your Laravel API URL

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication methods
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
      }
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Classes/Materials methods
  static Future<List<Map<String, dynamic>>> getClasses() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/classes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? data);
    } else {
      throw Exception('Failed to load classes: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getMaterials(int classId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/classes/$classId/materials'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? data);
    } else {
      throw Exception('Failed to load materials: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getMaterial(int materialId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/materials/$materialId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load material: ${response.body}');
    }
  }

  // Quiz methods
  static Future<Map<String, dynamic>> submitQuizAttempt(int materialId, int score, List<String> incorrectTopics) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/quiz-attempts'),
      headers: headers,
      body: jsonEncode({
        'material_id': materialId,
        'score': score,
        'incorrect_topics': incorrectTopics.join(','),
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit quiz: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getQuizAttempts() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/quiz-attempts'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? data);
    } else {
      throw Exception('Failed to load quiz attempts: ${response.body}');
    }
  }

  // User profile methods
  static Future<Map<String, dynamic>> getUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(String name, String email) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/user'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}