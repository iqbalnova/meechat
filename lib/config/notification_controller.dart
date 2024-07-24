import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as type;
import 'package:meechat/main.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:meechat/utils/styles.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final Map<String, dynamic>? payload = receivedAction.payload;

    // Check if payload is not null and get notificationtype and argument values
    final String? notifType = payload?['notificationType'] as String?;

    if (globalKey.currentState != null) {
      switch (notifType) {
        case 'inviteUser':
          globalKey.currentState?.pushNamed(AppRoutes.friendRequest);
          break;
        case 'message':
          final String room = payload?['room'] as String;
          final String receiverName = payload?['receiverName'] as String;

          globalKey.currentState?.pushNamed(AppRoutes.chatRoom, arguments: {
            'room': type.Room(
              id: jsonDecode(room)['id'],
              type: null,
              users: const [],
              imageUrl: jsonDecode(room)['users'][1]['imageUrl'],
            ),
            'receiverName': receiverName,
            'receiverUID': '',
            'senderName': '',
          });
          break;
        default:
          globalKey.currentState?.pushNamed(AppRoutes.main);
          break;
      }
    } else {
      if (kDebugMode) {
        print('Navigator key is null');
      }
    }
  }

  // Local Notification Service
  void initializeLocalChannel() {
    AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      // null,
      'resource://drawable/notif_icon',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: whiteColor,
            importance: NotificationImportance.High),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
    );
  }

  void requestNotificationPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example, you can show a dialog to ask for permission
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  int _createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  void createNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueId(),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }
}
