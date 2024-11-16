import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pg2_app/screens/Friend_service.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final FriendService _friendService = FriendService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      _allUsers = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((user) => user['uid'] != _currentUserId) // Exclude the current user
          .toList();
      setState(() {
        _filteredUsers = _allUsers;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final username = user['username']?.toString().toLowerCase() ?? '';
        return username.contains(query);
      }).toList();
    });
  }

  Future<void> _sendFriendRequest(String targetUserId) async {
    if (_currentUserId == null) return;
    try {
      await _friendService.sendFriendRequest(_currentUserId!, targetUserId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent')),
      );
    } catch (e) {
      print("Error sending friend request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by username',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return ListTile(
                          title: Text(user['username'] ?? 'Unknown'),
                          subtitle: Text(user['email'] ?? 'No email'),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add),
                            onPressed: () {
                              _sendFriendRequest(user['uid']);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}