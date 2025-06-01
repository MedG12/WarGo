import 'package:flutter/material.dart';
import 'package:wargo/models/chatMessage.dart';
import 'package:wargo/widgets/chatBubble.dart';

class ChatDetailsScreen extends StatelessWidget {
  const ChatDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sioamy Uhuy')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true, // Untuk chat terbaru di bawah
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ChatBubble(
                    message: message,
                    isMe: message.sender == 'me',
                  );
                },
              ),
            ),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: () {}),
        ],
      ),
    );
  }
}
