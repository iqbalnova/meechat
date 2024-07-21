import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:meechat/utils/styles.dart';
import 'package:meechat/utils/util.dart';

class AllUser extends StatefulWidget {
  const AllUser({super.key});

  @override
  State<AllUser> createState() => _AllUserState();
}

class _AllUserState extends State<AllUser> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool _isFetching = false;

  Future<void> _sendFriendRequest(
      types.User otherUser, context, String receiverName) async {
    if (_isFetching) return; // Prevent multiple fetches

    setState(() {
      _isFetching = true;
    });

    try {
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'senderId': currentUserId,
        'receiverId': otherUser.id,
        'receiverName': receiverName,
        'status':
            'pending', // Possible values: 'pending', 'accepted', 'rejected'
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Friend request sent to $receiverName',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle any errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sending friend request to $receiverName',
          ),
          backgroundColor: redColor,
        ),
      );
      throw ('Error sending friend request: $e');
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Widget _buildUserListTile(types.User user, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueGrey,
        radius: 25,
        child:
            Text('${index + 1}', style: const TextStyle(color: Colors.white)),
      ),
      title: Text(getUserName(user)),
      subtitle: Text(user.lastName ?? ''),
      onTap: () {
        _sendFriendRequest(user, context, getUserName(user));
      },
    );
  }

  Widget _buildUserList(List<types.User> users) {
    return ListView.separated(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserListTile(user, index);
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<types.User>>(
      stream: FirebaseChatCore.instance.users(),
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

        final users = snapshot.data ?? [];

        return _buildUserList(users);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Add More Friends!',
            style: whiteTextStyle.merge(titleTextStyle)),
        backgroundColor: primaryColor,
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }
}
