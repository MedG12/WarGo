import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wargo/screens/map_screen.dart';
import 'package:wargo/screens/user/chats_screen.dart';
import 'package:wargo/screens/user/home.dart';
import 'package:wargo/screens/user/profile_screen.dart';
// import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/widgets/navItem.dart';
import 'package:wargo/widgets/navItemProfile.dart';

class UserMainScreen extends StatefulWidget {
  final int preferredIndex;
  final LatLng? merchantLocation;
  const UserMainScreen({
    Key? key,
    this.preferredIndex = 0,
    this.merchantLocation,
  }) : super(key: key);

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  late int _currentIndex;
  late final PageController _pageController; // 1. Deklarasikan di sini

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.preferredIndex;
    _pageController = PageController(initialPage: _currentIndex);

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
    print("Merchant Location: ${widget.merchantLocation}");
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
            MapScreen(initialLocation: widget.merchantLocation),
            ChatsScreen(),
            ProfileScreen(),
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
            icon: navItemProfile(context, _currentIndex == 3),
            label: '',
          ),
        ],
      ),
    );
  }
}
