import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/screens/map_screen.dart';
import 'package:wargo/screens/user/chats_screen.dart';
import 'package:wargo/screens/user/home.dart';
import 'package:wargo/screens/user/profile_screen.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/widgets/navItem.dart';
import 'package:wargo/widgets/navItemProfile.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({Key? key}) : super(key: key);

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationService>(context, listen: false).loadCachedLocation();
      Provider.of<LocationService>(context, listen: false).fetchLocation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
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
          children: [HomeScreen(), MapScreen(), ChatsScreen(), ProfileScreen()],
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
            icon: navItemProfile(context, _currentIndex == 3),
            label: '',
          ),
        ],
      ),
    );
  }
}
