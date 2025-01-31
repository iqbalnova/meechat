import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:meechat/feature/auth/presentation/widgets/button_widget.dart';
import 'package:meechat/feature/core/presentation/screens/main_screen.dart';
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

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Chat',
          style: whiteTextStyle.merge(titleTextStyle),
        ),
        actions: [
          FriendRequestWidget(currentUserId: currentUserId),
        ],
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add New Friends to Chat!',
                    style: TextStyle(fontSize: 16, color: greyColor),
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                  SizedBox(
                    width: 160,
                    child: CustomButton(
                        onTap: () {
                          MainScreen.navigateToPage(context, 0);
                        },
                        label: 'Add Friends'),
                  )
                ],
              ),
            );
          }

          final rooms = snapshot.data!;
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
              return 0;
            }
          });

          return ListView.separated(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: _buildAvatar(room),
                title: Text(
                  room.name ?? '',
                  style: blackTextStyle,
                ),
                subtitle: _buildLastMessage(room),
                trailing: _buildLastUpdateChat(room),
                onTap: () => _onRoomTap(context, room),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }

  Widget _buildLastMessage(types.Room room) {
    return StreamBuilder<List<types.Message>>(
      stream: FirebaseChatCore.instance.messages(room),
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'Lets chatting!',
            style: TextStyle(color: primaryColor),
          );
        }

        final firstMessage = snapshot.data!.first;
        final isCurrentUser = firstMessage.author.id == currentUserId;

        return Row(
          children: [
            if (isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.check,
                  size: 16.0,
                  color: primaryColor,
                ),
              ),
            Expanded(
              child: Text(
                firstMessage is types.TextMessage
                    ? firstMessage.text
                    : 'Media message',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLastUpdateChat(types.Room room) {
    String formatUpdatedAt(int? timestamp) {
      if (timestamp == null) return 'Unknown';

      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final DateFormat timeFormatter = DateFormat('HH:mm');
      final DateFormat dateFormatter = DateFormat('MM/dd');

      if (dateTime.isAfter(today)) {
        return timeFormatter.format(dateTime);
      } else if (dateTime.isAtSameMomentAs(yesterday)) {
        return 'Yesterday';
      } else {
        return dateFormatter.format(dateTime);
      }
    }

    return StreamBuilder<List<types.Message>>(
      stream: FirebaseChatCore.instance.messages(room),
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Icon(
            Icons.chat,
            color: primaryColor,
          );
        }

        final firstMessage = snapshot.data!.first;
        return Text(
          firstMessage is types.TextMessage
              ? formatUpdatedAt(firstMessage.updatedAt)
              : '',
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  void _onRoomTap(BuildContext context, types.Room room) {
    final receiver = room.users.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => const types.User(id: ''),
    );

    final sender = room.users.firstWhere(
      (user) => user.id == currentUserId,
      orElse: () => const types.User(id: ''),
    );

    Navigator.pushNamed(
      context,
      AppRoutes.chatRoom,
      arguments: {
        'room': room,
        'receiverName': room.name,
        'receiverUID': receiver.id,
        'senderName': getUserName(sender),
      },
    );
  }

  Widget _buildAvatar(types.Room room) {
    const color = Colors.transparent;
    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        radius: 20,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: room.imageUrl!,
                cacheManager: customCacheManager,
                // placeholder: (context, url) =>
                //     const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                  radius: 20,
                ),
              )
            : Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}

class FriendRequestWidget extends StatelessWidget {
  const FriendRequestWidget({
    super.key,
    required this.currentUserId,
  });

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
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
            child: SizedBox(),
          );
        }

        final int length = snapshot.data?.docs.length ?? 0;

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.friendRequest);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.person_search,
                  size: 28,
                  color: Colors.white,
                ),
                if (length > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      child: Center(
                        child: Text(
                          '$length',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
