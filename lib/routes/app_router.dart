import 'package:flutter/material.dart';
import 'package:meechat/feature/auth/presentation/screens/login_screen.dart';
import 'package:meechat/feature/auth/presentation/screens/register_screen.dart';
import 'package:meechat/feature/chat/presentation/screens/chat_room.dart';
import 'package:meechat/feature/chat/presentation/screens/friend_request.dart';
import 'package:meechat/feature/core/presentation/screens/main_screen.dart';
import 'package:meechat/feature/core/presentation/screens/splash_screen.dart';
import 'package:meechat/routes/app_routes.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) {
      return Builder(
        builder: (BuildContext context) {
          switch (settings.name) {
            case AppRoutes.splash:
              return const SplashScreen();
            case AppRoutes.main:
              return const MainScreen();
            case AppRoutes.login:
              return const LoginScreen();
            case AppRoutes.register:
              return const RegisterScreen();
            case AppRoutes.chatRoom:
              final Map<String, dynamic> args =
                  settings.arguments as Map<String, dynamic>;
              return ChatRoom(
                receiverName: args['receiverName'],
                room: args['room'],
                receiverUID: args['receiverUID'],
                senderName: args['senderName'],
              );
            case AppRoutes.friendRequest:
              return const FriendRequests();
            default:
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Check Named Routes',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                ),
              );
          }
        },
      );
    });
  }
}
