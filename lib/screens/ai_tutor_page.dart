import 'package:flutter/material.dart';

class AiTutorPage extends StatefulWidget {
  const AiTutorPage({super.key});

  @override
  State<AiTutorPage> createState() => _AiTutorPageState();
}

class _AiTutorPageState extends State<AiTutorPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'message': 'Hello! I\'m your AI Tutor. How can I help you with your studies today?',
      'isUser': false,
      'timestamp': DateTime.now().toIso8601String(),
    }
  ];
  bool _isTyping = false;

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'message': message,
        'isUser': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'message': _getAIResponse(message),
            'isUser': false,
            'timestamp': DateTime.now().toIso8601String(),
          });
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('math') || message.contains('matematika')) {
      return 'Matematika adalah ilmu yang menarik! Bisakah Anda beri contoh soal yang ingin Anda pelajari? Saya bisa membantu menjelaskan konsep aljabar, geometri, atau kalkulus.';
    } else if (message.contains('programming') || message.contains('pemrograman')) {
      return 'Pemrograman itu menyenangkan! Apa bahasa pemrograman yang ingin Anda pelajari? Saya bisa membantu dengan Python, JavaScript, Dart, atau bahasa lainnya.';
    } else if (message.contains('science') || message.contains('sains')) {
      return 'Sains mencakup banyak bidang menarik! Apakah Anda tertarik dengan fisika, kimia, biologi, atau ilmu komputer?';
    } else if (message.contains('help') || message.contains('bantuan')) {
      return 'Saya di sini untuk membantu! Anda bisa bertanya tentang:\n• Penjelasan materi pelajaran\n• Bantuan mengerjakan soal\n• Rekomendasi cara belajar\n• Tips ujian\n\nApa yang ingin Anda tanyakan?';
    } else {
      return 'Terima kasih atas pertanyaannya! Saya akan membantu Anda belajar. Bisakah Anda beri tahu saya lebih spesifik tentang topik yang ingin dipelajari?';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  'message': 'Hello! I\'m your AI Tutor. How can I help you with your studies today?',
                  'isUser': false,
                  'timestamp': DateTime.now().toIso8601String(),
                });
              });
            },
            tooltip: 'New Conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const _TypingIndicator();
                }

                final message = _messages[index];
                return _ChatBubble(
                  message: message['message'],
                  isUser: message['isUser'],
                  timestamp: message['timestamp'],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything about your studies...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isTyping ? null : _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? timestamp;

  const _ChatBubble({
    required this.message,
    required this.isUser,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTimestamp(timestamp!),
                  style: TextStyle(
                    color: isUser ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SizedBox(
          width: 60,
          height: 40,
          child: Card(
            child: Center(
              child: Text(
                'AI is typing...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}