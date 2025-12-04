import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_page.dart';

class SubjectDetailPage extends StatefulWidget {
  final int classId;
  final String className;

  const SubjectDetailPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  List<Map<String, dynamic>> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);
    try {
      final materials = await ApiService.getMaterials(widget.classId);
      setState(() {
        _materials = materials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load materials: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.library_books, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No materials available yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(
                          material['title'] ?? 'Untitled Material',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Type: ${material['type'] ?? 'Unknown'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (material['content_url'] != null)
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.play_circle, size: 48),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                if (material['topic_tags'] != null)
                                  Wrap(
                                    spacing: 8,
                                    children: (material['topic_tags'] as String)
                                        .split(',')
                                        .map((tag) => Chip(
                                              label: Text(tag.trim()),
                                              backgroundColor: Colors.blue.withOpacity(0.1),
                                            ))
                                        .toList(),
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => QuizPage(
                                              materialId: material['id'],
                                              materialTitle: material['title'] ?? 'Quiz',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.quiz),
                                      label: const Text('Take Quiz'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Mark as completed
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Lesson marked as completed!')),
                                        );
                                      },
                                      icon: const Icon(Icons.check),
                                      label: const Text('Mark Complete'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}