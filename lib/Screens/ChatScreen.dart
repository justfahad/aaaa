import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser!.uid;

  void _sendMessage() async {
    final message = _messageController.text;
    if (message.isEmpty) return;

    try {
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      
      // Add the new message to the chat document
      await chatRef.update({
        'messages': FieldValue.arrayUnion([
          {
            'senderId': userId,
            'message': message,
            'timestamp': Timestamp.now(),
          }
        ]),
        'last_message': message,  // Update the last message
      });

      _messageController.clear();  // Clear the input field
    } catch (error) {
      print("Failed to send message: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No messages.'));
                }

                final chatData = snapshot.data!.data() as Map<String, dynamic>;
                final messages = chatData['messages'] as List;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isOwnMessage = message['senderId'] == userId;

                    return ListTile(
                      title: Align(
                        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isOwnMessage ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(
                              color: isOwnMessage ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
