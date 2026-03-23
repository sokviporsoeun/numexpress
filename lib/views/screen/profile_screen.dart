// ============================================================
// FILE: lib/screens/profile_screen.dart
// PURPOSE: Shows user profile info + settings menu + logout
//          User info (name, email) comes from Firebase Auth
//          and Firestore "users" collection
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numexpress/views/theme/colors.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();

  // Store user name after loading from Firestore
  String userName  = 'Loading...';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Load user name from Firestore and email from Firebase Auth
  void _loadUserInfo() async {
    String name = await authService.getUserName();
    User? user  = authService.currentUser;

    if (mounted) {
      setState(() {
        userName  = name;
        userEmail = user?.email ?? '';
      });
    }
  }

  // Show a confirmation dialog before logging out
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold, color: kBrown),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kGray)),
          ),
          // Confirm logout
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await authService.logout();
              if (mounted) {
                // Go back to login screen and clear all routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) =>  LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: kRose, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Profile header with gradient ─────────
            Container(
              width:  double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kBrown, Color(0xFF7A3B1E)],
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: Column(
                children: [
                  // Profile avatar
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius:          44,
                        backgroundColor: kRoseLight,
                        child: ,
                      ),
                      // Edit button on avatar
                      Positioned(
                        right:  0,
                        bottom: 0,
                        child: Container(
                          width:  28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: kRose,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit, color: kWhite, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // User name from Firestore
                  Text(
                    userName,
                    style: const TextStyle(
                      color:      kCream,
                      fontSize:   22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email from Firebase Auth
                  Text(
                    userEmail,
                    style: TextStyle(
                      color:   kGoldLight.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats row ─────────────────────────────
            // Pulled up to overlap the header
            Container(
              margin: const EdgeInsets.fromLTRB(20, -24, 20, 24),
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color:        kWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color:     Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    offset:    const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('12',   'Orders'),
                  // Vertical divider
                  Container(width: 1, height: 36, color: kGrayLight),
                  _statItem('3',    'Favorites'),
                  Container(width: 1, height: 36, color: kGrayLight),
                  _statItem('4.9★', 'My Rating'),
                ],
              ),
            ),

            // ── Menu items ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _menuItem(
                    icon:  Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => _showComingSoon(context),
                  ),
                  _menuItem(
                    icon:  Icons.location_on_outlined,
                    label: 'Saved Addresses',
                    onTap: () => _showComingSoon(context),
                  ),
                  _menuItem(
                    icon:  Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => _showComingSoon(context),
                  ),
                  _menuItem(
                    icon:  Icons.credit_card_outlined,
                    label: 'Payment Methods',
                    onTap: () => _showComingSoon(context),
                  ),
                  _menuItem(
                    icon:  Icons.card_giftcard_outlined,
                    label: 'Rewards & Points',
                    onTap: () => _showComingSoon(context),
                  ),
                  _menuItem(
                    icon:  Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => _showComingSoon(context),
                  ),

                  const SizedBox(height: 8),

                  // Logout - in red
                  _menuItem(
                    icon:      Icons.logout,
                    label:     'Logout',
                    textColor: kRose,
                    onTap:     _confirmLogout,
                  ),

                  const SizedBox(height: 24),

                  // App version
                  const Text(
                    'Sweet Layers v1.0.0',
                    style: TextStyle(color: kGray, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stat number + label ────────────────────────────────────
  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize:   20,
            fontWeight: FontWeight.bold,
            color:      kRose,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: kGray, fontSize: 12),
        ),
      ],
    );
  }

  // ── Menu row item ──────────────────────────────────────────
  Widget _menuItem({
    required IconData     icon,
    required String       label,
    required VoidCallback onTap,
    Color                 textColor = kBrown,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:        kWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:     Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color:      textColor,
                fontSize:   15,
                fontWeight: textColor == kRose
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: kGray, size: 20),
          ],
        ),
      ),
    );
  }

  // Placeholder for features not built yet
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:         Text('Coming soon! 🚀'),
        backgroundColor: kBrown,
        behavior:        SnackBarBehavior.floating,
      ),
    );
  }
}