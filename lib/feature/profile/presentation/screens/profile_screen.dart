import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:meechat/config/firebase_service.dart';
import 'package:meechat/routes/app_routes.dart';
import 'package:meechat/utils/styles.dart';

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

  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0XFFB5E2E2).withOpacity(0.4),
          border: Border.all(color: const Color(0XFFB5E2E2))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34.r,
            backgroundImage: _userData?['imageUrl'] != null
                ? NetworkImage(_userData?['imageUrl'])
                : null,
          ),
          SizedBox(
            width: 16.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatFullName(
                  _userData?['firstName'],
                  _userData?['lastName'],
                ),
                style: blackTextStyle.merge(semiBoldStyle),
              ),
              Text(_userData?['email'] ?? ''),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    VoidCallback? onTap,
    required IconData leadingIcon,
    Color? foregroundColor,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 4.h),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: Icon(
              leadingIcon,
              color: foregroundColor,
            ), // Ganti dengan ikon yang diinginkan
            title: Text(
              title,
              style: TextStyle(color: foregroundColor),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: foregroundColor,
            ), // Ikon panah kanan
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildAvatar(),
        // _buildCard(
        //   title: 'Edit Profile',
        //   onTap: () {},
        //   leadingIcon: Icons.edit_sharp,
        // ),
        _buildCard(
          title: 'Logout',
          onTap: () {
            GetIt.instance<FirebaseService>().signOut();
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
          leadingIcon: Icons.logout,
          foregroundColor: redColor,
        ),
      ],
    );
  }
}
