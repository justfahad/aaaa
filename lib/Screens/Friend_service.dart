import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sends a friend request from currentUserId to targetUserId
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    try {
      await _firestore.collection('users').doc(targetUserId).collection('friendRequests').doc(currentUserId).set({
        'senderId': currentUserId,
        'status': 'pending',  // status can be 'pending', 'accepted', or 'rejected'
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Friend request sent from $currentUserId to $targetUserId');
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  // Accepts a friend request from senderId to currentUserId
  Future<void> acceptFriendRequest(String currentUserId, String senderId) async {
    try {
      // Update the request status to 'accepted'
      await _firestore.collection('users').doc(currentUserId).collection('friendRequests').doc(senderId).update({
        'status': 'accepted',
      });

      // Add each other as friends
      await _firestore.collection('users').doc(currentUserId).collection('friends').doc(senderId).set({
        'friendId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('users').doc(senderId).collection('friends').doc(currentUserId).set({
        'friendId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Friend request accepted between $currentUserId and $senderId');
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  // Rejects a friend request from senderId to currentUserId
  Future<void> rejectFriendRequest(String currentUserId, String senderId) async {
    try {
      // Update the request status to 'rejected'
      await _firestore.collection('users').doc(currentUserId).collection('friendRequests').doc(senderId).update({
        'status': 'rejected',
      });

      print('Friend request rejected from $senderId by $currentUserId');
    } catch (e) {
      print('Error rejecting friend request: $e');
      rethrow;
    }
  }

  // Cancels a friend request sent from currentUserId to targetUserId
  Future<void> cancelFriendRequest(String currentUserId, String targetUserId) async {
    try {
      await _firestore.collection('users').doc(targetUserId).collection('friendRequests').doc(currentUserId).delete();

      print('Friend request canceled from $currentUserId to $targetUserId');
    } catch (e) {
      print('Error canceling friend request: $e');
      rethrow;
    }
  }

  // Checks if there is an active friend request between two users
  Future<bool> hasActiveFriendRequest(String currentUserId, String targetUserId) async {
    try {
      final requestDoc = await _firestore.collection('users').doc(targetUserId).collection('friendRequests').doc(currentUserId).get();
      return requestDoc.exists && requestDoc['status'] == 'pending';
    } catch (e) {
      print('Error checking friend request status: $e');
      return false;
    }
  }
}