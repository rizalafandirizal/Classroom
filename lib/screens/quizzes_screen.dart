import 'package:flutter/material.dart';

class QuizzesScreen extends StatelessWidget {
  final String classId;

  const QuizzesScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Online Quizzes - Coming Soon'),
    );
  }
}