import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'class_detail_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> availableClasses = [];
  List<Map<String, dynamic>> enrolledClasses = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load enrolled classes
      final enrolledResponse = await supabase
          .from('class_enrollments')
          .select('''
            class_id,
            classes!inner(
              id, title, description, start_date, end_date, max_students,
              subjects(name),
              teacher_id
            )
          ''')
          .eq('user_id', userId)
          .eq('status', 'active');

      enrolledClasses = (enrolledResponse as List<dynamic>).map((item) => {
        ...(item['classes'] as Map<String, dynamic>),
        'enrolled': true,
      }).toList();

      // Load available classes (not enrolled)
      final availableResponse = await supabase
          .from('classes')
          .select('''
            id, title, description, start_date, end_date, max_students,
            subjects(name),
            teacher_id
          ''')
          .eq('is_active', true)
          .not('id', 'in', '(${enrolledClasses.map((c) => c['id']).join(',')})');

      availableClasses = availableResponse.map((item) => {
        ...item,
        'enrolled': false,
      }).toList();

    } catch (e) {
      print('Error loading classes: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _enrollInClass(String classId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.rpc('enroll_student', params: {
        'class_uuid': classId,
        'student_uuid': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mendaftar kelas!')),
      );

      _loadClasses(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendaftar kelas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelas Online'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Terdaftar'),
              Tab(text: 'Tersedia'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildClassesList(enrolledClasses, true),
                  _buildClassesList(availableClasses, false),
                ],
              ),
      ),
    );
  }

  Widget _buildClassesList(List<Map<String, dynamic>> classes, bool isEnrolled) {
    if (classes.isEmpty) {
      return Center(
        child: Text(
          isEnrolled
              ? 'Belum ada kelas yang diikuti'
              : 'Tidak ada kelas tersedia',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classData = classes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClassDetailScreen(classData: classData),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          classData['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isEnrolled)
                        const Icon(Icons.check_circle, color: Colors.green)
                      else
                        ElevatedButton(
                          onPressed: () => _enrollInClass(classData['id']),
                          child: const Text('Daftar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    classData['description'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.subject, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        classData['subjects']?['name'] ?? 'Tidak ada subjek',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(classData['start_date'], classData['end_date']),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateRange(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'Tanggal tidak tersedia';

    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);

    return '${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';
  }
}