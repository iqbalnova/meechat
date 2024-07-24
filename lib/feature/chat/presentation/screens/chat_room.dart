import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/utils/styles.dart';
import 'package:meechat/utils/util.dart';

class ChatRoom extends StatefulWidget {
  final types.Room room;
  final String receiverName;
  final String receiverUID;
  final String senderName;

  const ChatRoom({
    super.key,
    required this.room,
    required this.receiverName,
    required this.receiverUID,
    required this.senderName,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String receiverToken = '';

  @override
  void initState() {
    super.initState();
    _fetchReceiverToken();
  }

  Future<void> _fetchReceiverToken() async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(widget.receiverUID).get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final token = userData['tokens'];
        setState(() {
          receiverToken = token;
        });
      } else {
        if (kDebugMode) {
          print('Document not found for UID: ${widget.receiverUID}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching receiver token: $e');
      }
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    // Implement logic if needed
  }

  void _sendMessage(types.PartialText message) {
    if (message.text.isEmpty) return; // Check if message text is empty

    FirebaseChatCore.instance.sendMessage(message, widget.room.id);
    FirebaseService().sendNotification(
      title: widget.senderName,
      token: receiverToken,
      body: message.text,
      notifType: 'message',
      room: jsonEncode(widget.room),
      receiverName: widget.senderName,
    );
    // argument: jsonEncode(
    //   {
    //     'room': widget.room,
    //     'receiverName': widget.senderName,
    //   },
    // ));
  }

  void _handleMessageLongPress(BuildContext context, types.Message message) {
    if (message.author.id == FirebaseChatCore.instance.firebaseUser?.uid) {
      _showMessageOptions(context, message);
    }
  }

  void _showMessageOptions(BuildContext context, types.Message message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(message);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: redColor,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: redColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message);
              },
            ),
            SizedBox(
              height: 32.h,
            ),
          ],
        );
      },
    );
  }

  void _editMessage(types.Message message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final controller =
            TextEditingController(text: (message as types.TextMessage).text);
        return AlertDialog(
          title: Text(
            'Edit Message',
            style: blackTextStyle,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: null,
            decoration: const InputDecoration(hintText: 'Enter new message'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final updatedMessage =
                      (message).copyWith(text: controller.text);
                  FirebaseChatCore.instance
                      .updateMessage(updatedMessage, widget.room.id);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(types.Message message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Message',
            style: blackTextStyle,
          ),
          content: const Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseChatCore.instance
                    .deleteMessage(widget.room.id, message.id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      foregroundColor: whiteColor,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: widget.room.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: widget.room.imageUrl!,
                    cacheManager: customCacheManager,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 20,
                    ),
                  )
                : const Icon(Icons.person), // Handle null case
          ),
          const SizedBox(width: 14),
          Text(
            widget.receiverName,
            style: whiteTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      backgroundColor: primaryColor,
    );
  }

  Widget _buildChatStream(types.Room room) {
    return StreamBuilder<List<types.Message>>(
      initialData: const [],
      stream: FirebaseChatCore.instance.messages(room),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        return Chat(
          messages: messages,
          onMessageTap: _handleMessageTap,
          onSendPressed: _sendMessage,
          onMessageLongPress: _handleMessageLongPress,
          user: types.User(
            id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
          ),
          theme: DefaultChatTheme(
            inputBackgroundColor: greyColor,
            primaryColor: primaryColor,
            secondaryColor: greyColor.withOpacity(0.1),
            inputBorderRadius:
                BorderRadius.vertical(top: Radius.circular(10.r)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: StreamBuilder<types.Room>(
        stream: FirebaseChatCore.instance.room(widget.room.id),
        builder: (context, roomSnapshot) {
          if (!roomSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildChatStream(roomSnapshot.data!);
        },
      ),
    );
  }
}
