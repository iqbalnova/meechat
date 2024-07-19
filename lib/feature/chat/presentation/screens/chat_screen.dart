import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:meechat/utils/styles.dart';
import 'package:meechat/utils/util.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // User? _user;

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      // FirebaseAuth.instance.authStateChanges().listen((User? user) {
      //   setState(() {
      //     _user = user;
      //   });
      // });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // void _handlePressed(
  //     types.User otherUser, context, String receiverName) async {
  //   final room = await FirebaseChatCore.instance.createRoom(otherUser);

  //   Navigator.pushNamed(
  //     context,
  //     AppRoutes.chatRoom,
  //     arguments: {
  //       'room': room,
  //       'receiverName': receiverName,
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Chat', style: whiteTextStyle.merge(titleTextStyle)),
        backgroundColor: primaryColor,
        centerTitle: false,
      ),
      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(),
        initialData: const [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('Add New Friends to Chat!'),
            );
          }
          // Misalkan rooms adalah daftar ruangan yang ingin Anda tampilkan
          final rooms = snapshot.data!;

          // Urutkan daftar berdasarkan updatedAt secara descending
          rooms.sort((a, b) {
            final int? updatedAtA = a.updatedAt;
            final int? updatedAtB = b.updatedAt;

            if (updatedAtA != null && updatedAtB != null) {
              return updatedAtB.compareTo(updatedAtA);
            } else if (updatedAtA == null && updatedAtB != null) {
              return -1;
            } else if (updatedAtA != null && updatedAtB == null) {
              return 1;
            } else {
              return 0; // Jika keduanya null, tidak ada perubahan urutan
            }
          });

          return ListView.separated(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: _buildAvatar(room),
                title: Text(room.name ?? ''),
                subtitle: Text(room.updatedAt.toString()),
                onTap: () {
                  // Get receiver uid from collection firestore
                  final receiver = room.users.firstWhere(
                    (user) => user.id != currentUserId,
                    orElse: () => const types.User(
                      id: '',
                    ),
                  );
                  // Get Sender Name from firestore
                  final sender = room.users.firstWhere(
                    (user) => user.id == currentUserId,
                    orElse: () => const types.User(
                      id: '',
                    ),
                  );
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatRoom,
                    arguments: {
                      'room': room,
                      'receiverName': room.name,
                      'receiverUID': receiver.id,
                      'senderName': getUserName(sender)
                    },
                  );
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

  Widget _buildAvatar(types.Room room) {
    var color = Colors.transparent;

    // if (room.type == types.RoomType.direct) {
    //   try {
    //     final otherUser = room.users.firstWhere(
    //       (u) => u.id != _user!.uid,
    //     );

    //     color = Colors.amber;
    //   } catch (e) {
    //     // Do nothing if other user is not found.
    //   }
    // }

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }
}
