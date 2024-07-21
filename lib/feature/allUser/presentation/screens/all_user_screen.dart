import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:meechat/utils/styles.dart';
import 'package:meechat/utils/util.dart';

class AllUser extends StatefulWidget {
  const AllUser({super.key});

  @override
  State<AllUser> createState() => _AllUserState();
}

class _AllUserState extends State<AllUser> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _sendFriendRequest(
    types.User otherUser,
    context,
    String receiverName,
  ) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        throw 'Current user is not authenticated';
      }

      final requestStatus =
          await _checkExistingRequest(currentUserId, otherUser.id);

      if (requestStatus != null) {
        await _handleExistingRequest(
            requestStatus, otherUser, receiverName, context);
        return;
      }

      final reverseRequestStatus =
          await _checkExistingRequest(otherUser.id, currentUserId);

      if (reverseRequestStatus != null) {
        await _handleExistingRequest(
            reverseRequestStatus, otherUser, receiverName, context);
        return;
      }

      await _sendNewRequest(currentUserId, otherUser.id, receiverName);
      showSnackBar(
          context, 'Friend request sent to $receiverName', Colors.green);
    } catch (e) {
      showSnackBar(
          context, 'Error sending friend request to $receiverName', Colors.red);
    }
  }

  Future<String?> _checkExistingRequest(
      String senderId, String receiverId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['status'];
    }
    return null;
  }

  Future<void> _handleExistingRequest(
    String status,
    types.User otherUser,
    String receiverName,
    context,
  ) async {
    if (status == 'pending') {
      showSnackBar(context, 'Friend request already sent to $receiverName',
          Colors.orange);
    } else if (status == 'accepted') {
      final room = await FirebaseChatCore.instance.createRoom(otherUser);

      Navigator.pushNamed(
        context,
        AppRoutes.chatRoom,
        arguments: {
          'room': room,
          'receiverName': receiverName,
          'receiverUID': otherUser.id,
          'senderName': '',
        },
      );
    }
  }

  Future<void> _sendNewRequest(
    String senderId,
    String receiverId,
    String receiverName,
  ) async {
    // Get the current user's details
    final userDetails = await _getUserDetails(senderId);
    final senderName = '${userDetails['firstName']} ${userDetails['lastName']}';

    // // Get the receiver's token
    final receiverDetails = await _getUserDetails(receiverId);
    final receiverToken = receiverDetails['token'];

    await FirebaseFirestore.instance.collection('friend_requests').add({
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Send notification
    FirebaseService().sendNotification(
      title: 'New Friend Request',
      token: receiverToken!,
      body: '$senderName wants to be your friend. Tap to view and respond.',
    );
  }

  Future<Map<String, String>> _getUserDetails(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        return _defaultUserDetails();
      }

      final data = docSnapshot.data() as Map<String, dynamic>;

      final tokens = (data['tokens']);
      final firstName = data['firstName'];
      final lastName = data['lastName'];

      return {
        'token': tokens,
        'firstName': firstName,
        'lastName': lastName,
      };
    } catch (e) {
      // Handle any errors that might occur during data retrieval
      if (kDebugMode) {
        print('Error retrieving user details: $e');
      }
      return _defaultUserDetails(); // Return default values in case of an error
    }
  }

  /// Returns default values for user details.
  Map<String, String> _defaultUserDetails() {
    return {
      'token': '',
      'firstName': '',
      'lastName': '',
    };
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
