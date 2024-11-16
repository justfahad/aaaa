import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pg2_app/screens/Friend_service.dart';
class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final FriendService _friendService = FriendService(); // Initialize FriendService
  late String _currentUserId; // Declare current user ID

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid; // Retrieve the current user ID
  }

  Future<String> _getUserEmail(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDoc['email'] ?? 'Unknown'; // Retrieve the email or return 'Unknown'
    } catch (e) {
      print('Error fetching user email: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUserId)
            .collection('friendRequests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No friend requests'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final senderId = request['senderId'];

              return FutureBuilder<String>(
                future: _getUserEmail(senderId), // Fetch email using senderId
                builder: (context, emailSnapshot) {
                  if (emailSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading...')); // Placeholder while loading email
                  }
                  if (emailSnapshot.hasError) {
                    return const ListTile(title: Text('Error loading email'));
                  }
                  if (!emailSnapshot.hasData || emailSnapshot.data!.isEmpty) {
                    return const ListTile(title: Text('No email found'));
                  }

                  final senderEmail = emailSnapshot.data!;

                  return ListTile(
                    title: Text('Request from: $senderEmail'), // Display sender's email
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            try {
                              await _friendService.acceptFriendRequest(_currentUserId, senderId);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request accepted')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error accepting request: $e')));
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _friendService.rejectFriendRequest(_currentUserId, senderId);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request rejected')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error rejecting request: $e')));
                            }
                          },
                        ),
                      ],
                    ),
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
