import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wargo/providers/navigationState.dart';

import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/services/merchant/merchant_service.dart';

import 'screens/signin_screen.dart';
import 'package:wargo/screens/merchant/merchant_main_screen.dart';
import 'package:wargo/screens/user/user_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase dengan file firebase_options.dart yang sudah ada
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ytfhvpbeqahcaytsgckm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl0Zmh2cGJlcWFoY2F5dHNnY2ttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4MzQ0NzIsImV4cCI6MjA2NDQxMDQ3Mn0.90biNLFG4pHgty37B63cXp8BS7FMH-rnaaQKSCqprCE',
  );
  //uncomment untuk auto logout
  // await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        Provider(create: (_) => MerchantService()),
      ],
      child: MaterialApp(
        title: 'Firebase Auth App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: const ColorScheme.light(primary: Color(0xFF483AA0)),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              // print('user role: ${authService.role}');
              switch (authService.role) {
                case 'merchant':
                  return const MerchantMainScreen();
                case 'user':
                  return const UserMainScreen();
                default:
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
              }
            } else {
              // User is not signed in, show sign in screen
              return const SignInScreen();
              // return Text('Silahkan Login');
            }
          },
        );
      },
    );
  }
}
