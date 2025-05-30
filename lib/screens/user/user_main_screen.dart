import 'package:flutter/material.dart';
import 'package:wargo/screens/map_screen.dart';
import 'package:wargo/screens/user/home.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/widgets/navItem.dart';
import 'package:wargo/widgets/navItemProfile.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({Key? key}) : super(key: key);

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  AuthService authService = AuthService();
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            HomeScreen(),
            MapScreen(),
            Container(color: Colors.blue, child: Center(child: Text('Chat'))),
            Container(
              color: Colors.yellow,
              child: Center(child: Text('Profile')),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0E2148),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 10,
        items: [
          BottomNavigationBarItem(
            icon: navItem(Icons.home_outlined, Icons.home, _currentIndex == 0),
            label: '', // Tambahkan label kosong
          ),
          BottomNavigationBarItem(
            icon: navItem(Icons.map_outlined, Icons.map, _currentIndex == 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: navItem(
              Icons.chat_bubble_outline,
              Icons.chat_bubble,
              _currentIndex == 2,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: navItemProfile(
              _currentIndex == 3,
              authService.currentUser!.photoURL!,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
