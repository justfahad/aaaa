import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pg2_app/screens/ChatScreen.dart';

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chats available.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat.id;
              final participants = chat['participants'] as List;

              // Get the other participant (friend)
              final friendId = participants.firstWhere((id) => id != userId);
              
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                builder: (context, friendSnapshot) {
                  if (friendSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }
                  final friendData = friendSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(chatId: chatId),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friendData['image_url'] ?? ''),
                    ),
                    title: Text(friendData['username'] ?? 'No Name'),
                    subtitle: Text(chat['last_message'] ?? ''),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
