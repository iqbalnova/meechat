import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/config/notification_controller.dart';
import 'package:meechat/main.dart';
import 'package:meechat/routes/app_router.dart';
import 'package:meechat/routes/app_routes.dart';

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseService _instance = FirebaseService();
  @override
  void initState() {
    super.initState();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final Map<String, dynamic> data = message.data;
      String? currentPath;
      globalKey.currentState?.popUntil((route) {
        currentPath = route.settings.name;
        return true;
      });
      if (currentPath != AppRoutes.chatRoom) {
        GetIt.instance<NotificationController>().createNotification(
          title: data['title'],
          body: data['body'],
          payload: {
            'notificationtype': data['notificationType'],
            'argument': data['argument'] ?? '',
          },
        );
      } else {
        // Change to vibration
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _instance.setupFCM();
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: !kDebugMode,
          theme: ThemeData(
            useMaterial3: true,
          ),
          navigatorKey: widget.navigatorKey,
          onGenerateRoute: GetIt.instance<AppRouter>().onGenerateRoute,
        );
      },
    );
  }
}
