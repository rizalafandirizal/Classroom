import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialsScreen extends StatefulWidget {
  final String classId;

  const MaterialsScreen({super.key, required this.classId});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> materials = [];
  bool isTeacher = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
    _checkTeacherRole();
  }

  Future<void> _loadMaterials() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('class_materials')
          .select('*')
          .eq('class_id', widget.classId)
          .eq('is_published', true)
          .order('order_index');

      materials = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading materials: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _checkTeacherRole() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('classes')
          .select('teacher_id')
          .eq('id', widget.classId)
          .single();

      setState(() {
        isTeacher = response['teacher_id'] == userId;
      });
    } catch (e) {
      print('Error checking teacher role: $e');
    }
  }

  Future<void> _markAsCompleted(String materialId, bool isCompleted) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (isCompleted) {
        await supabase.from('material_progress').upsert({
          'user_id': userId,
          'material_id': materialId,
          'is_completed': true,
          'completion_date': DateTime.now().toIso8601String(),
        });
      } else {
        await supabase
            .from('material_progress')
            .delete()
            .eq('user_id', userId)
            .eq('material_id', materialId);
      }

      // Refresh materials to update progress
      _loadMaterials();
    } catch (e) {
      print('Error updating progress: $e');
    }
  }

  Future<void> _openMaterial(Map<String, dynamic> material) async {
    final materialType = material['material_type'];
    final contentUrl = material['content_url'];
    final externalLink = material['external_link'];

    if (materialType == 'video' && contentUrl != null) {
      // For videos, you might want to use a video player
      // For now, we'll open in browser or external app
      if (await canLaunchUrl(Uri.parse(contentUrl))) {
        await launchUrl(Uri.parse(contentUrl));
      }
    } else if (materialType == 'pdf' && contentUrl != null) {
      if (await canLaunchUrl(Uri.parse(contentUrl))) {
        await launchUrl(Uri.parse(contentUrl));
      }
    } else if (materialType == 'link' && externalLink != null) {
      if (await canLaunchUrl(Uri.parse(externalLink))) {
        await launchUrl(Uri.parse(externalLink));
      }
    }
    // For articles, the content is displayed in the UI
  }

  IconData _getMaterialIcon(String materialType) {
    switch (materialType) {
      case 'video':
        return Icons.play_circle_fill;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'article':
        return Icons.article;
      case 'link':
        return Icons.link;
      default:
        return Icons.file_present;
    }
  }

  Color _getMaterialColor(String materialType) {
    switch (materialType) {
      case 'video':
        return Colors.red;
      case 'pdf':
        return Colors.blue;
      case 'article':
        return Colors.green;
      case 'link':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : materials.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada materi untuk kelas ini',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final material = materials[index];
                    final materialType = material['material_type'] ?? 'unknown';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _openMaterial(material),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getMaterialIcon(materialType),
                                    color: _getMaterialColor(materialType),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          material['title'] ?? 'Untitled',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          materialType.toUpperCase(),
                                          style: TextStyle(
                                            color: _getMaterialColor(materialType),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isTeacher)
                                    Checkbox(
                                      value: material['is_completed'] ?? false,
                                      onChanged: (value) {
                                        if (value != null) {
                                          _markAsCompleted(material['id'], value);
                                        }
                                      },
                                    ),
                                ],
                              ),
                              if (material['description'] != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  material['description'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                              if (materialType == 'article' && material['content_text'] != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    material['content_text'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to add material screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur tambah materi akan segera hadir')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}