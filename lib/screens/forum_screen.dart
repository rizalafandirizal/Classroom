import 'package:flutter/material.dart';

class ForumScreen extends StatelessWidget {
  final String classId;

  const ForumScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Forum Discussion - Coming Soon'),
    );
  }
}