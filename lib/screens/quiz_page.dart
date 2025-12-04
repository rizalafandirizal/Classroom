import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizPage extends StatefulWidget {
  final int materialId;
  final String materialTitle;

  const QuizPage({
    super.key,
    required this.materialId,
    required this.materialTitle,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'correctAnswer': 'Paris',
    },
    {
      'question': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctAnswer': '4',
    },
    {
      'question': 'What color is the sky?',
      'options': ['Green', 'Blue', 'Red', 'Yellow'],
      'correctAnswer': 'Blue',
    },
  ];

  String? _selectedAnswer;

  void _selectAnswer(String answer) {
    setState(() => _selectedAnswer = answer);
  }

  void _nextQuestion() {
    if (_selectedAnswer == _questions[_currentQuestionIndex]['correctAnswer']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final percentage = ((_score / _questions.length) * 100).round();

    setState(() => _quizCompleted = true);

    try {
      await ApiService.submitQuizAttempt(
        widget.materialId,
        percentage,
        [], // No incorrect topics for demo
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz completed! Score: $percentage%')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save quiz result: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      final percentage = ((_score / _questions.length) * 100).round();
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70 ? Icons.celebration : Icons.school,
                size: 80,
                color: percentage >= 70 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Completed!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: $percentage%',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Correct answers: $_score out of ${_questions.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Text(
                percentage >= 80
                    ? 'Excellent work! 🎉'
                    : percentage >= 60
                        ? 'Good job! Keep practicing.'
                        : 'Keep studying and try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Lesson'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.materialTitle}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${_currentQuestionIndex + 1}/${_questions.length}'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
            ),
            const SizedBox(height: 24),
            Text(
              currentQuestion['question'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...currentQuestion['options'].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _selectAnswer(option),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAnswer == option
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedAnswer == option
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: _selectedAnswer,
                          onChanged: (value) => _selectAnswer(value!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(option)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                        _selectedAnswer = null;
                      });
                    },
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _selectedAnswer != null ? _nextQuestion : null,
                  child: Text(_currentQuestionIndex == _questions.length - 1
                      ? 'Finish'
                      : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}