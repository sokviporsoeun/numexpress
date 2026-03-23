// ============================================================
// FILE: lib/widgets/my_button.dart
// PURPOSE: A reusable big button used throughout the app
//          Just pass label and onTap to use it anywhere
// ============================================================

import 'package:flutter/material.dart';
import 'package:numexpress/views/theme/colors.dart';


class MyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading; // show spinner when waiting for Firebase

  const MyButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          // Orange-red gradient look
          backgroundColor: kRose,
          foregroundColor: kWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 3,
        ),
        child: isLoading
            // Show spinning circle while loading
            ? const CircularProgressIndicator(color: kWhite, strokeWidth: 2)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}