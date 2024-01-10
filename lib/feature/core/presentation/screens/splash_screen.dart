import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/routes/app_routes.dart';
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
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront,
              size: 100.sp,
              color: primaryColor,
            ),
            Text(
              'Welcome to MeeChat',
              style: TextStyle(
                  fontSize: 18.sp,
                  color: primaryColor,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
