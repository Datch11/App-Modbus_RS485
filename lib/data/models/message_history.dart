/// Message history model
class MessageHistory {
  final String message;
  final List<int>? rawBytes; // Store raw bytes for hex display
  final DateTime timestamp;
  final bool isSent;
  final bool isSuccess;
  final String? errorMessage;

  MessageHistory({
    required this.message,
    this.rawBytes, // Optional: only for binary data
    required this.timestamp,
    required this.isSent,
    required this.isSuccess,
    this.errorMessage,
  });

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Check if message has raw bytes (for hex display)
  bool get hasRawBytes => rawBytes != null && rawBytes!.isNotEmpty;

  @override
  String toString() {
    return 'MessageHistory($formattedTime: $message)';
  }
}
