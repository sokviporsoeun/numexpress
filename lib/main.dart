// ============================================================
// FILE: lib/main.dart
// PURPOSE: This is where the app starts
//          - Initialize Firebase
//          - Show login screen OR home based on auth state
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numexpress/views/screen/login_screen.dart';
import 'package:numexpress/views/screen/main_screen.dart';
import 'package:numexpress/views/theme/colors.dart';



void main() async {
  // This is required before using Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Firebase (uses google-services.json you already added)
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweet Layers',
      debugShowCheckedModeBanner: false, // hide the debug banner
      theme: ThemeData(
        scaffoldBackgroundColor: kCream,
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(seedColor: kRose),
        useMaterial3: true,
      ),
      // AuthGate decides what to show first
      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE - Watches Firebase login state
// If user is logged in → show MainScreen (with bottom nav)
// If user is NOT logged in → show LoginScreen
// This automatically changes when user logs in or out
// ============================================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // This stream updates every time user logs in or out
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Still checking login state - show loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kCream,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎂', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: kRose),
                ],
              ),
            ),
          );
        }

        // User is logged in - go to main app
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // User is NOT logged in - go to login
        return  LoginScreen();
      },
    );
  }
}