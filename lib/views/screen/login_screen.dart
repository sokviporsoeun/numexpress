// ============================================================
// FILE: lib/screens/login_screen.dart
//
// WHY StatefulWidget?
//   → isLogin changes (toggle between Login/Register tab)
//   → isLoading changes (show/hide spinner on button)
//   → Both use setState() to rebuild UI
// ============================================================

import 'package:flutter/material.dart';
import 'package:numexpress/views/theme/colors.dart';

import '../services/auth_service.dart';
import '../widgets/my_button.dart';
import 'main_screen.dart';

// ✅ StatefulWidget — isLogin and isLoading change with setState()
class LoginScreen extends StatefulWidget {
  // No "const" here — this is StatefulWidget
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin   = true;  // changes when user taps Login/Register tab
  bool isLoading = false; // changes when waiting for Firebase

  final nameCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();
  final phoneCtrl = TextEditingController();

  final AuthService authService = AuthService();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      showError('Please fill in all fields');
      return;
    }
    if (!isLogin && nameCtrl.text.trim().isEmpty) {
      showError('Please enter your name');
      return;
    }

    setState(() => isLoading = true); // show spinner

    String? error;
    if (isLogin) {
      error = await authService.login(
        email: emailCtrl.text.trim(), password: passCtrl.text.trim());
    } else {
      error = await authService.register(
        name:     nameCtrl.text.trim(),
        email:    emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        phone:    phoneCtrl.text.trim());
    }

    // ✅ FIX: After any async call (await), the screen might already
    // be gone from the tree. Always check "mounted" before setState()
    // or using context. Without this check → crash on register/login.
    if (!mounted) return;

    setState(() => isLoading = false); // hide spinner

    if (error != null) {
      showError(error);
    } else {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => MainScreen()));
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kBrown, Color(0xFF7A3B1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎂', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 12),
                  Text('Sweet Layers',
                    style: TextStyle(color: kCream, fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Cakes made with love',
                    style: TextStyle(color: kGoldLight, fontSize: 14)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _tabButton('Login',    isActive: isLogin,
                        onTap: () => setState(() => isLogin = true)),
                      const SizedBox(width: 24),
                      _tabButton('Register', isActive: !isLogin,
                        onTap: () => setState(() => isLogin = false)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (!isLogin) ...[
                    _inputField(controller: nameCtrl,
                      hint: 'Full Name', icon: Icons.person_outline),
                    const SizedBox(height: 14),
                    _inputField(controller: phoneCtrl,
                      hint: 'Phone Number', icon: Icons.phone_outlined,
                      inputType: TextInputType.phone),
                    const SizedBox(height: 14),
                  ],
                  _inputField(controller: emailCtrl,
                    hint: 'Email Address', icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _inputField(controller: passCtrl,
                    hint: 'Password', icon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 28),
                  MyButton(
                    label:     isLogin ? 'Login' : 'Create Account',
                    isLoading: isLoading,
                    onTap:     handleSubmit,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin
                            ? "Don't have an account? Register"
                            : 'Already have an account? Login',
                        style: const TextStyle(
                          color: kRose, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(text,
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: isActive ? kBrown : kGray)),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3, width: isActive ? 40 : 0,
            decoration: BoxDecoration(
              color: kRose, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextField(
      controller:   controller,
      keyboardType: inputType,
      obscureText:  isPassword,
      decoration: InputDecoration(
        hintText:   hint,
        hintStyle:  const TextStyle(color: kGray),
        prefixIcon: Icon(icon, color: kGray),
        filled:     true,
        fillColor:  kGrayLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none),
      ),
    );
  }
}