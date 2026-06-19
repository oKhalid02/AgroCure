class ChatMessage {
  final String role; // "user" | "assistant"
  final String text;

  const ChatMessage({required this.role, required this.text});

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {'role': role, 'content': text};
}
