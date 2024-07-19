import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/utils/styles.dart';

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

  Future<void> fetchDataReceiver(String receiverUID) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(receiverUID).get();

      if (snapshot.exists) {
        // Dokumen ditemukan, Anda dapat mengakses datanya di sini
        var userData = snapshot.data() as Map<String, dynamic>;
        var token = userData['tokens'];
        setState(() {
          receiverToken = token;
        });
      } else {
        // Dokumen tidak ditemukan
        if (kDebugMode) {
          print('Dokumen tidak ditemukan untuk UID: $receiverUID');
        }
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataReceiver(widget.receiverUID);
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        }
      }
    }
  }

  void _sendMessage(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
    FirebaseService().sendNotification(
        title: widget.senderName, token: receiverToken, body: message.text);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          foregroundColor: whiteColor,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(widget.room.imageUrl!),
                radius: 20,
              ),
              const SizedBox(
                width: 14,
              ),
              Text(
                widget.receiverName,
                style: whiteTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          backgroundColor: primaryColor,
        ),
        body: StreamBuilder<types.Room>(
          stream: FirebaseChatCore.instance.room(widget.room.id),
          builder: (context, roomSnapshot) {
            if (!roomSnapshot.hasData) {
              // Handle loading state or return a loading widget
              return const CircularProgressIndicator();
            }

            return StreamBuilder<List<types.Message>>(
              initialData: const [],
              stream: FirebaseChatCore.instance.messages(roomSnapshot.data!),
              builder: (context, snapshot) => Chat(
                messages: snapshot.data ?? [],
                onMessageTap: _handleMessageTap,
                onSendPressed: _sendMessage,
                // isAttachmentUploading: _isAttachmentUploading,
                // onAttachmentPressed: _handleAtachmentPressed,
                // onPreviewDataFetched: _handlePreviewDataFetched,
                user: types.User(
                  id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                ),
                theme: DefaultChatTheme(
                    inputBackgroundColor: greyColor,
                    primaryColor: primaryColor,
                    secondaryColor: greyColor.withOpacity(0.1),
                    inputBorderRadius:
                        BorderRadius.vertical(top: Radius.circular(10.r))),
              ),
            );
          },
        ),
      );
}
