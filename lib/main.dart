import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:meechat/app.dart';
import 'package:meechat/config/locator.dart';
import 'package:meechat/firebase_options.dart';

final GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Locator().setupDepedencyInjection();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // print('User granted permission: ${settings.authorizationStatus}');

  print('User granted permission: ${settings.authorizationStatus}');

  runApp(MyApp(
    navigatorKey: globalKey,
  ));
}
