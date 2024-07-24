import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/config/notification_controller.dart';
import 'package:meechat/routes/app_router.dart';

class Locator {
  static final getIt = GetIt.instance;

  void setupDepedencyInjection() {
    getIt.registerSingleton<AppRouter>(AppRouter());
    getIt.registerSingleton<FirebaseService>(FirebaseService());
    getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
    getIt.registerSingleton<NotificationController>(NotificationController());
  }
}
