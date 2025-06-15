import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/screens/map_screen.dart';
import 'package:wargo/screens/user/chats_screen.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/screens/merchant/merchant_dashboard_screen.dart';
import 'package:wargo/screens/merchant/merchant_profile_screen.dart';

class MerchantMainScreen extends StatefulWidget {
  const MerchantMainScreen({super.key});

  @override
  State<MerchantMainScreen> createState() => _MerchantMainScreenState();
}

class _MerchantMainScreenState extends State<MerchantMainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions => [
    MerchantDashboardScreen(
      onNavigateToProfile: () => _onItemTapped(3),
    ), // Tab Home (Dashboard)
    MapScreen(),
    ChatsScreen(),
    MerchantProfileScreen(), // Tab Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    // Cleanup Geolocator jika diperlukan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return WillPopScope(
      onWillPop: () async {
        // Tampilkan dialog konfirmasi sebelum keluar
        final shouldPop = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Keluar Aplikasi'),
                content: const Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Tidak'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya'),
                  ),
                ],
              ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF483AA0),
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 8.0,
        ),
      ),
    );
  }
}
