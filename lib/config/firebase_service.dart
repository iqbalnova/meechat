// firebase_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Initialize Firebase
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Register a new user
  Future<UserCredential> registerWithEmailPassword(
      String email, String password, String firstName, String lastName) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // User? user = userCredential.user;
      // if (user != null) {
      //   await user.updateDisplayName(username);
      //   // Jika Anda memiliki URL foto profil, Anda juga dapat menggunakannya:
      //   // await user.updatePhotoURL(photoURL);

      //   await user.reload(); // Refresh user object
      //   user = FirebaseAuth.instance.currentUser; // Update the user variable
      // }

      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: firstName,
          id: userCredential.user!.uid,
          imageUrl: 'https://i.pravatar.cc/300?u=$email',
          lastName: lastName,
        ),
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // add user credential if doesn't already exist
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
      }, SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (kDebugMode) {
      print(FirebaseAuth.instance.signOut());
    }
    await FirebaseAuth.instance.signOut();
  }

  // Get the current user
  User? getCurrentUser() {
    if (kDebugMode) {
      print(FirebaseAuth.instance.currentUser);
    }
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        if (kDebugMode) {
          print('Account deleted successfully');
        }
      } else {
        if (kDebugMode) {
          print('No user is currently signed in');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
    }
  }

// Messaging purpose
  Future<void> saveTokenToDatabase(String token) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'tokens': token,
    });
  }

  Future<void> setupFCM() async {
    String? token = await FirebaseMessaging.instance.getToken();
    await saveTokenToDatabase(token!);
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message: $message");
    });

    // Handle when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Background Message: $message");
    });
  }

  Future<void> sendNotification(
      {required String title,
      required String body,
      required String token}) async {
    const String serverKey =
        'AAAASIChfXQ:APA91bFf1-x-Pqp-GdEDEt1QVIK5Q_64gpl2NLRSoiqK60hIzwk8xSZu_uCbLGTq-MvTKMJQi5clwKPFX-TZf9KQmcoNfP02r9lj8ECqLEj8I81jmkvQF9Jvp_89z4QoNQJF788OnE5H'; // Ganti dengan kunci server Firebase Anda
    const String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'title': title,
      'body': body,
    };

    final Map<String, dynamic> data = {
      'notification': notification,
      'to': token
    };

    final Dio dio = Dio();
    try {
      final Response response = await dio.post(
        fcmEndpoint,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
        ),
        data: jsonEncode(data),
      );

      if (kDebugMode) {
        print(response);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }
}
