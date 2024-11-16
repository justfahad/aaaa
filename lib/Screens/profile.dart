import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pg2_app/widget/user_image_picker.dart';
import 'package:pg2_app/screens/friend_request.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  String? _username;
  String? _email;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    setState(() {
      _username = userData['username'];
      _email = userData['email'];
      _imageUrl = userData['image_url'];
    });
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);

        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'image_url': imageUrl});

        setState(() {
          _imageUrl = imageUrl;
        });
      } catch (error) {
        print("Failed to upload image: $error");
      }
    }
  }

  Future<void> _removeFriend(String friendId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      // Remove the friend from the current user's friends list
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .delete();

      // Optional: Remove the current user from the friend's friends list
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(userId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend removed successfully')),
      );
    } catch (error) {
      print('Failed to remove friend: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove friend')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FriendRequestsScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (_imageUrl != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_imageUrl!),
              ),
            const SizedBox(height: 20),
            UserImagePicker(
              onPickImage: (pickedImage) {
                setState(() {
                  _selectedImage = pickedImage;
                });
                _uploadImage();
              },
            ),
            const SizedBox(height: 10),
            if (_username != null) Text(' $_username', style: TextStyle(fontSize: 18)),
            const Divider(height: 30, thickness: 2),

            // Friends List Section
            Text(
              'Friends List',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('friends')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('You have no friends yet.');
                }

                final friendsDocs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: friendsDocs.length,
                  itemBuilder: (context, index) {
                    final friendId = friendsDocs[index].id;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(friendId)
                          .get(),
                      builder: (context, friendSnapshot) {
                        if (friendSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(title: Text('Loading...'));
                        }
                        if (!friendSnapshot.hasData || !friendSnapshot.data!.exists) {
                          return ListTile(title: Text('Unknown Friend'));
                        }

                        final friendData = friendSnapshot.data!.data() as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(friendData['image_url'] ?? ''),
                            child: friendData['image_url'] == null
                                ? Icon(Icons.person)
                                : null,
                          ),
                          title: Text(friendData['username'] ?? 'No Name'),
                          subtitle: Text(friendData['email'] ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFriend(friendId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
