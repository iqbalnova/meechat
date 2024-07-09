import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:meechat/utils/util.dart';

class AllUser extends StatefulWidget {
  const AllUser({super.key});

  @override
  State<AllUser> createState() => _AllUserState();
}

class _AllUserState extends State<AllUser> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _handlePressed(
      types.User otherUser, context, String receiverName) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    Navigator.pushNamed(
      context,
      AppRoutes.chatRoom,
      arguments: {
        'room': room,
        'receiverName': receiverName,
        'receiverUID': '',
        'senderName': ''
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add More Friends!',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        centerTitle: false,
      ),
      body: StreamBuilder<List<types.User>>(
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

          // // Data dari Firestore
          // final List<QueryDocumentSnapshot<Map<String, dynamic>>> users =
          //     snapshot.data!.docs;

          // // Filter data untuk menghilangkan pengguna dengan UID yang sama dengan current user
          // final List<QueryDocumentSnapshot<Map<String, dynamic>>>
          //     filteredUsers = users.where((user) {
          //   final String chatUserId = user['uid'] ?? '';
          //   return chatUserId != currentUserId;
          // }).toList();

          return ListView.separated(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              // final userType =
              //     types.User(id: user['uid'], firstName: user['name']);

              // Gunakan data untuk membuat ListTile
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  radius: 25,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(getUserName(user)),
                subtitle: Text(user.lastName ?? ''),
                onTap: () {
                  _handlePressed(user, context, getUserName(user));
                },
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          );
        },
      ),
    );
  }
}
