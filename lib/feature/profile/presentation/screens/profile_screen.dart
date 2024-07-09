import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/routes/app_routes.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }

  String formatFullName(String? firstName, String? lastName) {
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  Future<void> initializeFlutterFire() async {
    try {
      final currentUser = GetIt.instance<FirebaseService>().getCurrentUser();

      DocumentSnapshot snapshot = await GetIt.instance<FirebaseFirestore>()
          .collection('users')
          .doc(currentUser?.uid)
          .get();

      Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        setState(() {
          _userData = userData;
        });
      } else {
        if (kDebugMode) {
          print('Error: Data is empty');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // GetIt.instance<FirebaseService>().signOut();
        // Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      child: ListView(
        children: [
          _buildAvatar(),
          _buildCard(
              title: formatFullName(
                _userData?['firstName'],
                _userData?['lastName'],
              ),
              onTap: () {}),
          _buildCard(
              title: 'Logout',
              onTap: () {
                GetIt.instance<FirebaseService>().signOut();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              })
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundImage: _userData?['imageUrl'] != null
              ? NetworkImage(_userData?['imageUrl'])
              : null,
        ),
      ],
    );
  }

  Widget _buildCard({required String title, VoidCallback? onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.0.r),
          child: Text(title),
        ),
      ),
    );
  }
}
