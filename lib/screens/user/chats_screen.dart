import 'package:flutter/material.dart';
import 'package:wargo/models/chatPreview.dart';
import 'package:wargo/screens/user/chat_details_screen.dart';
import 'package:wargo/services/messages_service.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              title: const Center(
                child: Text(
                  'Chats',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            StreamBuilder<List<ChatPreview>>(
              stream: MessagesService().getUserChats(),
              builder: (context, snapshot) {
                final chats = snapshot.data ?? [];
                if (chats.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Belum ada chat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chat = chats[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 239, 238, 238),
                            width: 0.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            8,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatDetailsScreen(),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(chat.peerPhotoUrl),
                          ),
                          title: Row(
                            children: [
                              Text(
                                chat.peerName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                chat.lastTimestamp.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            chat.lastMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }, childCount: chats.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
