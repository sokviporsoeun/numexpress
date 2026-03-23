// ============================================================
// FILE: lib/screens/main_screen.dart
// PURPOSE: The main screen with bottom navigation bar
//          Holds Home, Browse, Cart, Orders, Profile
//          Using setState to switch between tabs - beginner friendly
// ============================================================

import 'package:flutter/material.dart';
import 'package:numexpress/views/model/cart.dart';
import 'package:numexpress/views/theme/colors.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Which tab is currently showing (0 = Home, 1 = Cakes, etc.)
  int currentTab = 0;

  // All the screens - one per tab
  final List<Widget> screens =  [
    HomeScreen(),
    BrowseScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show the screen for the current tab
      body: screens[currentTab],

      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kWhite,
          border: Border(
            top: BorderSide(color: kGrayLight, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded,         Icons.home_outlined,          'Home'),
                _navItem(1, Icons.cake_rounded,         Icons.cake_outlined,          'Cakes'),
                _cartNavItem(), // Cart has a badge
                _navItem(3, Icons.receipt_long_rounded, Icons.receipt_long_outlined,  'Orders'),
                _navItem(4, Icons.person_rounded,       Icons.person_outlined,        'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Regular nav item
  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    bool isActive = currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        isActive ? kRoseLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? kRose : kGray,
              size:  22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize:   10,
                color:      isActive ? kRose : kGray,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cart nav item with badge showing item count
  Widget _cartNavItem() {
    bool isActive = currentTab == 2;
    int count = Cart.itemCount;

    return GestureDetector(
      onTap: () => setState(() => currentTab = 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        isActive ? kRoseLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cart icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive
                      ? Icons.shopping_cart_rounded
                      : Icons.shopping_cart_outlined,
                  color: isActive ? kRose : kGray,
                  size:  22,
                ),
                // Badge - only show if cart has items
                if (count > 0)
                  Positioned(
                    right: -8,
                    top:   -6,
                    child: Container(
                      width:  16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: kRose,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 9,
                            color:    kWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Cart',
              style: TextStyle(
                fontSize:   10,
                color:      isActive ? kRose : kGray,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}