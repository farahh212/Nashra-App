import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_viewModel.dart';
import 'message_model.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String userId;

  ChatScreen({required this.chatId, required this.userId});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatVM.getMessagesStream(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final messages = snapshot.data as List;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      MessageBubble(message: messages[index], isMe: messages[index].senderId == userId),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    chatVM.sendMessage(chatId, _controller.text, userId);
                    _controller.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
