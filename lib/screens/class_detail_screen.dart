import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'materials_screen.dart';
import 'forum_screen.dart';
import 'assignments_screen.dart';
import 'quizzes_screen.dart';
import 'participants_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const ClassDetailScreen({super.key, required this.classData});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classData['title'] ?? 'Detail Kelas'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Materi', icon: Icon(Icons.library_books)),
            Tab(text: 'Forum', icon: Icon(Icons.forum)),
            Tab(text: 'Tugas', icon: Icon(Icons.assignment)),
            Tab(text: 'Kuis', icon: Icon(Icons.quiz)),
            Tab(text: 'Peserta', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MaterialsScreen(classId: widget.classData['id']),
          ForumScreen(classId: widget.classData['id']),
          AssignmentsScreen(classId: widget.classData['id']),
          QuizzesScreen(classId: widget.classData['id']),
          ParticipantsScreen(classId: widget.classData['id']),
        ],
      ),
    );
  }
}