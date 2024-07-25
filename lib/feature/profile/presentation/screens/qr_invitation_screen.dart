import 'dart:convert'; // Import this for JSON encoding

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/feature/auth/presentation/widgets/button_widget.dart';
import 'package:meechat/feature/profile/presentation/widgets/qr_scanner_bottomsheet.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:meechat/utils/assets_manager.dart';
import 'package:meechat/utils/styles.dart';
import 'package:meechat/utils/util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class QrInvitationScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String imgUrl;
  final String id;

  const QrInvitationScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.imgUrl,
    required this.id,
  });

  @override
  State<QrInvitationScreen> createState() => _QrInvitationScreenState();
}

class _QrInvitationScreenState extends State<QrInvitationScreen> {
  double? _previousBrightness;
  late types.User currentUser;

  @override
  void initState() {
    super.initState();
    _setBrightnessToFull();
    // Initialize currentUser here
    currentUser = types.User(
      id: widget.id,
      firstName: widget.firstName,
      lastName: widget.lastName,
    );
  }

  @override
  void dispose() {
    _restorePreviousBrightness();
    super.dispose();
  }

  Future<void> _setBrightnessToFull() async {
    _previousBrightness =
        await ScreenBrightness().current; // Get the current brightness
    await ScreenBrightness().setScreenBrightness(1.0); // Set brightness to full
  }

  Future<void> _restorePreviousBrightness() async {
    if (_previousBrightness != null) {
      await ScreenBrightness().setScreenBrightness(
          _previousBrightness!); // Restore previous brightness
    }
  }

  void _showQRScanner() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return QRScannerBottomSheet(
          onRoomCreated: (data) {
            createRoom(data: data);
          },
        );
      },
    );
  }

  void createRoom({required String data, context}) async {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(data);

      // Auto accepted frien request
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'senderId': widget.id,
        'senderName': '${widget.firstName} ${widget.lastName}',
        'receiverId': jsonMap['id'],
        'receiverName': '${jsonMap['firstName']} ${jsonMap['lastName']}',
        'status': 'accepted',
        'timestamp': FieldValue.serverTimestamp(),
      });

      final otherUser = types.User(
          id: jsonMap['id'],
          firstName: jsonMap['firstName'],
          lastName: jsonMap['lastName']);
      final room = await FirebaseChatCore.instance.createRoom(otherUser);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.chatRoom,
        arguments: {
          'room': room,
          'receiverName': getUserName(otherUser),
          'receiverUID': '',
          'senderName': ''
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert currentUser to JSON string
    final currentUserJson = jsonEncode({
      'id': currentUser.id,
      'firstName': currentUser.firstName,
      'lastName': currentUser.lastName,
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Code',
          style: blackTextStyle.merge(titleTextStyle),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(40.sp),
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.firstName} ${widget.lastName}', // Adjusted to match your `fullName` usage
                        style: blackTextStyle.merge(semiBoldStyle),
                      ),
                      SizedBox(height: 14.r),
                      Container(
                        padding: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: QrImageView(
                          data:
                              currentUserJson, // Use the JSON string as the QR code data
                          version: QrVersions.auto,
                          size: 200.0,
                          padding: EdgeInsets.zero, // Remove padding if needed
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -34.r,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.imgUrl),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(6),
                      width: 40.sp,
                      height: 40.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: whiteColor,
                      ),
                      child: Image.asset(
                        AssetManager.splashIcon,
                        fit: BoxFit.cover,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 240.w,
              child: CustomButton(
                onTap: _showQRScanner,
                label: 'Scan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
