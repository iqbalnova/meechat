import 'package:flutter/material.dart';
import 'package:meechat/feature/allUser/presentation/screens/all_user_screen.dart';
import 'package:meechat/feature/chat/presentation/screens/chat_screen.dart';
import 'package:meechat/feature/profile/presentation/screens/profile_screen.dart';
import 'package:meechat/utils/styles.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void navigateToPage(BuildContext context, int index) {
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
    if (mainScreenState != null && mainScreenState._isValidIndex(index)) {
      mainScreenState._setIndex(index);
    }
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;
  final int _totalPages = 3; // Total number of pages in BottomNavigationBar

  void _setIndex(int index) {
    if (_isValidIndex(index)) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  bool _isValidIndex(int index) {
    return index >= 0 && index < _totalPages;
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const AllUser();
      case 1:
        return const Chat();
      case 2:
        return const Profile();
      default:
        return const OnDevScreen();
    }
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: greyColor,
      currentIndex: _currentIndex,
      onTap: _setIndex,
      items: _bottomNavigationBarItems(),
    );
  }

  List<BottomNavigationBarItem> _bottomNavigationBarItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.person_add),
        label: 'All User',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_sharp),
        label: 'Chat',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: buildBottomNavigationBar(),
      body: _buildBody(),
    );
  }
}

class OnDevScreen extends StatelessWidget {
  const OnDevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "ON DEV",
        style: blackTextStyle,
      ),
    );
  }
}
