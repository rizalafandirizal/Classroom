class MaterialModel {
  final int id;
  final String title;
  final List<String> topicTags;

  MaterialModel({
    required this.id,
    required this.title,
    required this.topicTags,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int,
      title: json['title'] as String,
      topicTags: List<String>.from(json['topic_tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic_tags': topicTags,
    };
  }
}