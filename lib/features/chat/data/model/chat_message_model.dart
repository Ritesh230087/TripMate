class ChatMessage {
  final String text;
  final String senderId;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.senderId, required this.timestamp});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? json['message'],
      senderId: json['senderId'],
      timestamp: DateTime.parse(json['timestamp'] ?? json['date']),
    );
  }
}