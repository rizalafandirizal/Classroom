import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'classes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  // Dashboard data
  double weeklyProgress = 0.0;
  List<Map<String, dynamic>> currentSubjects = [];
  List<Map<String, dynamic>> todaysSchedule = [];
  List<Map<String, dynamic>> upcomingAssignments = [];
  List<Map<String, dynamic>> aiRecommendations = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load all dashboard data in parallel
      await Future.wait([
        _loadWeeklyProgress(userId),
        _loadCurrentSubjects(userId),
        _loadTodaysSchedule(userId),
        _loadUpcomingAssignments(userId),
        _loadAIRecommendations(userId),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadWeeklyProgress(String userId) async {
    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final response = await supabase
        .from('learning_progress')
        .select('progress_percentage')
        .eq('user_id', userId)
        .gte('week_start', weekStart.toIso8601String().split('T')[0])
        .lte('week_start', weekEnd.toIso8601String().split('T')[0]);

    if (response.isNotEmpty) {
      final totalProgress = response.fold<double>(0, (sum, item) => sum + (item['progress_percentage'] ?? 0));
      weeklyProgress = totalProgress / response.length;
    }
  }

  Future<void> _loadCurrentSubjects(String userId) async {
    final response = await supabase
        .from('user_subjects')
        .select('''
          subject_id,
          subjects!inner(name, description)
        ''')
        .eq('user_id', userId);

    currentSubjects = response.map((item) => {
      'id': item['subject_id'],
      'name': item['subjects']['name'],
      'description': item['subjects']['description'],
    }).toList();
  }

  Future<void> _loadTodaysSchedule(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await supabase
        .from('class_schedules')
        .select('''
          title, description, start_time, end_time, location,
          subjects!inner(name)
        ''')
        .eq('user_id', userId)
        .eq('scheduled_date', today)
        .order('start_time');

    todaysSchedule = response.map((item) => {
      'title': item['title'],
      'subject': item['subjects']['name'],
      'description': item['description'],
      'start_time': item['start_time'],
      'end_time': item['end_time'],
      'location': item['location'],
    }).toList();
  }

  Future<void> _loadUpcomingAssignments(String userId) async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    final response = await supabase
        .from('assignments')
        .select('''
          title, description, due_date, priority, status,
          subjects!inner(name)
        ''')
        .eq('user_id', userId)
        .gte('due_date', now.toIso8601String())
        .lte('due_date', nextWeek.toIso8601String())
        .neq('status', 'completed')
        .order('due_date');

    upcomingAssignments = response.map((item) => {
      'title': item['title'],
      'subject': item['subjects']['name'],
      'description': item['description'],
      'due_date': DateTime.parse(item['due_date']),
      'priority': item['priority'],
      'status': item['status'],
    }).toList();
  }

  Future<void> _loadAIRecommendations(String userId) async {
    // First, trigger AI recommendation generation
    await supabase.rpc('generate_ai_recommendations', params: {'user_uuid': userId});

    // Then fetch the recommendations
    final response = await supabase
        .from('ai_recommendations')
        .select('''
          recommendation_type, title, description, priority_score,
          subjects(name)
        ''')
        .eq('user_id', userId)
        .order('priority_score', ascending: false)
        .limit(5);

    aiRecommendations = response.map((item) => {
      'type': item['recommendation_type'],
      'title': item['title'],
      'description': item['description'],
      'priority_score': item['priority_score'],
      'subject': item['subjects']?['name'],
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Classroom Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClassesScreen()),
              );
            },
            tooltip: 'Kelas Online',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly Progress
                  _buildWeeklyProgressCard(),

                  const SizedBox(height: 20),

                  // Current Subjects
                  _buildCurrentSubjectsCard(),

                  const SizedBox(height: 20),

                  // Today's Schedule
                  _buildTodaysScheduleCard(),

                  const SizedBox(height: 20),

                  // Upcoming Assignments
                  _buildUpcomingAssignmentsCard(),

                  const SizedBox(height: 20),

                  // AI Recommendations
                  _buildAIRecommendationsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Belajar Mingguan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: weeklyProgress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                weeklyProgress >= 80 ? Colors.green : weeklyProgress >= 60 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text('${weeklyProgress.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubjectsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mata Pelajaran yang Diikuti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            currentSubjects.isEmpty
                ? const Text('Belum ada mata pelajaran yang diikuti')
                : Column(
                    children: currentSubjects.map((subject) => ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(subject['name']),
                      subtitle: Text(subject['description'] ?? ''),
                    )).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysScheduleCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jadwal Kelas Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            todaysSchedule.isEmpty
                ? const Text('Tidak ada jadwal kelas hari ini')
                : Column(
                    children: todaysSchedule.map((schedule) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(schedule['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${schedule['subject']}'),
                            Text('${schedule['start_time']} - ${schedule['end_time']}'),
                            if (schedule['location'] != null) Text(schedule['location']),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAssignmentsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tugas Mendekati Deadline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            upcomingAssignments.isEmpty
                ? const Text('Tidak ada tugas mendekati deadline')
                : Column(
                    children: upcomingAssignments.map((assignment) => Card(
                      color: _getPriorityColor(assignment['priority']),
                      child: ListTile(
                        leading: const Icon(Icons.assignment),
                        title: Text(assignment['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${assignment['subject']}'),
                            Text('Deadline: ${_formatDate(assignment['due_date'])}'),
                            Text('Prioritas: ${assignment['priority']}'),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rekomendasi AI',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            aiRecommendations.isEmpty
                ? const Text('Tidak ada rekomendasi saat ini')
                : Column(
                    children: aiRecommendations.map((rec) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.lightbulb),
                        title: Text(rec['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec['description']),
                            if (rec['subject'] != null) Text('Mata Pelajaran: ${rec['subject']}'),
                            Text('Prioritas: ${(rec['priority_score'] * 100).toInt()}%'),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red[50]!;
      case 'medium':
        return Colors.orange[50]!;
      case 'low':
        return Colors.green[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
