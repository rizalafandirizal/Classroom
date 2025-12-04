import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Map<String, dynamic>> _quizAttempts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);
    try {
      final attempts = await ApiService.getQuizAttempts();
      setState(() {
        _quizAttempts = attempts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load progress: ${e.toString()}')),
        );
      }
    }
  }

  Map<String, dynamic> _calculateStats() {
    if (_quizAttempts.isEmpty) {
      return {
        'totalAttempts': 0,
        'averageScore': 0,
        'highestScore': 0,
        'totalScore': 0,
      };
    }

    int totalScore = 0;
    int highestScore = 0;

    for (var attempt in _quizAttempts) {
      int score = attempt['score'] ?? 0;
      totalScore += score;
      if (score > highestScore) highestScore = score;
    }

    return {
      'totalAttempts': _quizAttempts.length,
      'averageScore': (totalScore / _quizAttempts.length).round(),
      'highestScore': highestScore,
      'totalScore': totalScore,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Attempts',
                          value: stats['totalAttempts'].toString(),
                          icon: Icons.quiz,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Average Score',
                          value: '${stats['averageScore']}%',
                          icon: Icons.grade,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Highest Score',
                          value: '${stats['highestScore']}%',
                          icon: Icons.emoji_events,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Score',
                          value: stats['totalScore'].toString(),
                          icon: Icons.score,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Recent Quiz Attempts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ..._quizAttempts.map((attempt) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            (attempt['score'] ?? 0) >= 70
                                ? Icons.check_circle
                                : Icons.error,
                            color: (attempt['score'] ?? 0) >= 70
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text('Quiz Score: ${attempt['score'] ?? 0}%'),
                          subtitle: Text(
                            'Attempted: ${attempt['created_at'] ?? 'Unknown time'}',
                          ),
                          trailing: Chip(
                            label: Text('${attempt['score'] ?? 0}%'),
                            backgroundColor: (attempt['score'] ?? 0) >= 70
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                          ),
                        ),
                      )),

                  if (_quizAttempts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No quiz attempts yet. Start taking quizzes to see your progress!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}