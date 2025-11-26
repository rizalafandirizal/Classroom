import 'package:flutter/material.dart';
import '../services/recommendation_service.dart';
import '../models/material_model.dart';
import 'recommendation_card.dart';

class RecommendationListScreen extends StatefulWidget {
  const RecommendationListScreen({super.key});

  @override
  State<RecommendationListScreen> createState() => _RecommendationListScreenState();
}

class _RecommendationListScreenState extends State<RecommendationListScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final RecommendationService _service = RecommendationService();
  List<MaterialModel> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchRecommendations() async {
    final userIdText = _userIdController.text.trim();
    if (userIdText.isEmpty) {
      setState(() {
        _error = 'Please enter a user ID';
      });
      return;
    }

    final userId = int.tryParse(userIdText);
    if (userId == null) {
      setState(() {
        _error = 'Please enter a valid user ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recommendations = await _service.fetchRecommendations(userId);
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Classroom Recommendations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchRecommendations,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Fetch Recommendations'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            Expanded(
              child: _recommendations.isEmpty && !_isLoading
                  ? const Center(child: Text('No recommendations yet'))
                  : ListView.builder(
                      itemCount: _recommendations.length,
                      itemBuilder: (context, index) {
                        final material = _recommendations[index];
                        return RecommendationCard(material: material);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}