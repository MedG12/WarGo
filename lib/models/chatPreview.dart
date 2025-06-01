class ChatPreview {
  final String chatId;
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;
  final String lastMessage;
  final int lastTimestamp;

  ChatPreview({
    required this.chatId,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
    required this.lastMessage,
    required this.lastTimestamp,
  });
}
