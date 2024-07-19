import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:meechat/utils/assets_manager.dart';
import 'package:meechat/utils/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkLoginStatus();
    super.initState();
  }

  Future<void> checkLoginStatus() async {
    // Contoh: Gantilah logika ini dengan cara Anda memeriksa apakah pengguna sudah login
    final FirebaseService firebaseService = FirebaseService();

    Future.delayed(const Duration(seconds: 3), () {
      if (firebaseService.getCurrentUser() != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: primaryColor,
              child: Image.asset(
                AssetManager.splashImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Image.asset(
              AssetManager.splashIcon,
              width: 120.w,
              height: 120.h,
            ),
          ),
        ],
      ),
    );
  }
}
