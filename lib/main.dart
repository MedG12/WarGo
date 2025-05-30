import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wargo/screens/user/user_main_screen.dart';
import 'services/auth_service.dart';
import 'screens/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase dengan file firebase_options.dart yang sudah ada
  await Firebase.initializeApp();
  //uncomment untuk auto logout
  await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
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
              switch (authService.role) {
                case 'merchant':
                  return const HomeMerchScreen();
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

class HomeMerchScreen extends StatelessWidget {
  const HomeMerchScreen({super.key});
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Merchant'),
        backgroundColor: const Color(0xFF0E2148),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'Hello ${user?.displayName ?? user?.email ?? 'User'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => authService.signOut(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF483AA0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
