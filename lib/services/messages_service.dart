import 'package:firebase_database/firebase_database.dart';
import 'package:wargo/models/chatPreview.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/user_service.dart';

class Message {
  final String senderId;
  final String text;
  final int timestamp;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map data) {
    return Message(
      senderId: data['senderId'],
      text: data['text'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'senderId': senderId, 'text': text, 'timestamp': timestamp};
  }
}

class MessagesService {
  final _db = FirebaseDatabase.instance;
  final _auth = AuthService();

  Stream<List<ChatPreview>> getUserChats() async* {
    final currentUser = _auth.currentUser;

    if (currentUser == null) yield [];

    final chatMetaRef = _db.ref().child('chats_metadata');
    final stream = chatMetaRef.onValue;

    await for (final event in stream) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        yield [];
        continue;
      }
      List<ChatPreview> previews = [];

      for (final entry in data.entries) {
        final chatId = entry.key;
        final value = Map<String, dynamic>.from(entry.value);
        final participants = Map<String, dynamic>.from(
          value['participants'] ?? {},
        );
        if (!participants.containsKey(currentUser!.uid)) continue;

        // Tentukan peerId
        final peerId = participants.keys.firstWhere(
          (id) => id != currentUser.uid,
          orElse: () => '',
        );

        if (peerId.isEmpty) continue;

        // Ambil data user dari Firestore
        final userData = await UserService().getUserData(peerId);
        final peerName = userData['name'] ?? 'Unknown';
        final peerPhotoUrl = userData['photoUrl'] ?? '';

        previews.add(
          ChatPreview(
            chatId: chatId,
            peerId: peerId,
            peerName: peerName,
            peerPhotoUrl: peerPhotoUrl,
            lastMessage: value['lastMessage'] ?? '',
            lastTimestamp: value['lastTimestamp'] ?? 0,
          ),
        );
      }

      previews.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));
      yield previews;
    }
  }

  String _getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> sendMessage(String receiverId, String text) async {
    final currentUser = _auth.currentUser!;
    final chatId = _getChatId(currentUser.uid, receiverId);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newMessageRef = _db.ref('messages/$chatId').push();

    final messageData = {
      'senderId': currentUser.uid,
      'text': text,
      'timestamp': timestamp,
    };

    // Simpan pesanhttps://console.firebase.google.com/u/0/project/wargo-e9839/hosting
    await newMessageRef.set(messageData);

    // Update metadata
    final metadataRef = _db.ref('chat_metadata/$chatId');
    await metadataRef.update({
      'lastMessage': text,
      'lastTimestamp': timestamp,
      'participants/${currentUser.uid}': true,
      'participants/$receiverId': true,
    });
  }

  Stream<List<Message>> getMessagesStream(String receiverId) {
    final currentUser = _auth.currentUser!;
    final chatId = _getChatId(currentUser.uid, receiverId);
    final messagesRef = _db.ref('messages/$chatId').orderByChild('timestamp');

    return messagesRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries.map((entry) {
        final msg = Map<String, dynamic>.from(entry.value);
        return Message.fromMap(msg);
      }).toList();
    });
  }

  Future<List<Message>> fetchMessages(String receiverId) async {
    final currentUser = _auth.currentUser!;
    final chatId = _getChatId(currentUser.uid, receiverId);
    final snapshot =
        await _db.ref('messages/$chatId').orderByChild('timestamp').get();

    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final msg = Map<String, dynamic>.from(entry.value);
      return Message.fromMap(msg);
    }).toList();
  }
}
