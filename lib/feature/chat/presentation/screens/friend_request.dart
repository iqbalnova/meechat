import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:meechat/routes/app_routes.dart';
import 'package:meechat/utils/styles.dart';
import 'package:meechat/utils/util.dart';

class FriendRequests extends StatefulWidget {
  const FriendRequests({super.key});

  @override
  State<FriendRequests> createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _acceptRequest(DocumentSnapshot request, context) async {
    try {
      final otherUserId = request['senderId'];
      final otherUserSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();
      final otherUser = types.User(
          id: otherUserId,
          firstName: otherUserSnapshot['firstName'],
          lastName: otherUserSnapshot['lastName']);

      final room = await FirebaseChatCore.instance.createRoom(otherUser);

      await request.reference.update({'status': 'accepted'});

      Navigator.pushNamed(
        context,
        AppRoutes.chatRoom,
        arguments: {
          'room': room,
          'receiverName': getUserName(otherUser),
          'receiverUID': otherUserId,
          'senderName': ''
        },
      );
    } catch (e) {
      // Handle any errors here
      throw ('Error accepting friend request: $e');
    }
  }

  // Future<void> _rejectRequest(DocumentSnapshot request) async {
  //   try {
  //     await request.reference.update({'status': 'rejected'});
  //   } catch (e) {
  //     // Handle any errors here
  //     throw ('Error rejecting friend request: $e');
  //   }
  // }

  Future<void> _rejectRequest(DocumentSnapshot request) async {
    try {
      // Delete the document from the 'friend_requests' collection
      await request.reference.delete();
    } catch (e) {
      // Handle any errors here
      throw ('Error rejecting friend request: $e');
    }
  }

  Widget _buildRequestListTile(DocumentSnapshot request) {
    return ListTile(
      title: Text(request['senderName']),
      subtitle: const Text('Friend request'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _acceptRequest(request, context),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _rejectRequest(request),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<DocumentSnapshot> requests) {
    return ListView.separated(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestListTile(request);
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No friend requests at the moment.',
              style: TextStyle(fontSize: 16, color: greyColor),
            ),
          );
        }

        return _buildRequestList(requests);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: whiteColor,
        title: Text('Friend Requests',
            style: whiteTextStyle.merge(titleTextStyle)),
        backgroundColor: primaryColor,
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }
}
