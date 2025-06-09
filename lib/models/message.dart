class Message {
  final String senderId;
  final String text;
  final int timestamp;
  final String senderName;

  Message({
    required this.senderName,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map data) {
    return Message(
      senderName: data['senderName'],
      senderId: data['senderId'],
      text: data['text'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'senderId': senderId, 'text': text, 'timestamp': timestamp};
  }
} 
