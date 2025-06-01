class ChatMessage {
  final String sender;
  final String text;
  final String time;

  ChatMessage({required this.sender, required this.text, required this.time});
}

// Contoh data chat
List<ChatMessage> messages = [
  ChatMessage(
    sender: 'Sioamy',
    text: 'Mang nanti jangan lupa ke rumah yah anterin pesananan saya oke bang',
    time: '10:00',
  ),
  ChatMessage(
    sender: 'me',
    text: 'Oke siap, nanti jam 2 aku kesana',
    time: '10:02',
  ),
  ChatMessage(
    sender: 'Sioamy',
    text: 'Makasih ya! Jangan lupa bawa yang lengkap',
    time: '10:03',
  ),
];
