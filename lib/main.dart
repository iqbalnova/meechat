import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:meechat/app.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/config/locator.dart';
import 'package:meechat/config/notification_controller.dart';
import 'package:meechat/firebase_options.dart';

final GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final Map<String, dynamic> data = message.data;
  if (data.isNotEmpty) {
    NotificationController().createNotification(
      title: data['title'],
      body: data['body'],
      payload: {
        'notificationType': data['notificationType'],
        'room': data['room'] ?? '',
        'receiverName': data['receiverName'] ?? '',
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Locator().setupDepedencyInjection();
  FirebaseService().requestPermission();
  NotificationController().initializeLocalChannel();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MyApp(
    navigatorKey: globalKey,
  ));
}
