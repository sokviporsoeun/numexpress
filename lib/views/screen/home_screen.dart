// ============================================================
// FILE: lib/screens/home_screen.dart
//
// WHY StatefulWidget?
//   → userName is loaded from Firebase AFTER the screen opens
//   → We call setState() to update userName when it loads
//   → initState() is called once when screen first appears
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:numexpress/views/model/cake.dart';
import 'package:numexpress/views/theme/colors.dart';
// import '../colors.dart';
import '../services/auth_service.dart';
import '../services/cake_service.dart';
// import '../models/cake.dart';
import '../widgets/cake_card.dart';
import 'cake_detail_screen.dart';
import 'browse_screen.dart';

// ✅ StatefulWidget — because userName changes with setState()
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CakeService cakeService = CakeService();
  final AuthService authService = AuthService();

  // This variable CHANGES after Firebase loads → needs setState()
  String userName = 'Friend';

  @override
  void initState() {
    super.initState();
    _loadUserName(); // load from Firebase when screen opens
  }

  void _loadUserName() async {
    String name = await authService.getUserName();
    // setState() rebuilds the screen with the new name
    if (mounted) setState(() => userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildPromoBanner(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text('Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kBrown)),
            ),
            const SizedBox(height: 14),
            _buildCategories(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🔥 Bestsellers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kBrown)),
                  TextButton(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BrowseScreen())),
                    child: const Text('See all',
                      style: TextStyle(color: kRose, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Cake>>(
              stream: cakeService.getBestsellers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: kRose)));
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Could not load cakes.'));
                }
                List<Cake> cakes = snapshot.data ?? [];
                if (cakes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No cakes yet. Add cakes in Firestore.',
                      style: TextStyle(color: kGray)));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: cakes.map((cake) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBestsellerRow(context, cake),
                    )).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kBrown, Color(0xFF7A3B1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Good Morning ☀️',
                    style: TextStyle(color: kGoldLight, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(userName,
                    style: const TextStyle(
                      color: kCream, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: kRoseLight,
                child: Text('👩', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BrowseScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.white54, size: 18),
                  SizedBox(width: 10),
                  Text('Search your perfect cake...',
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    // ✅ FIX: Flutter Container does NOT allow negative margins
    // Use Transform.translate to move the banner UP by 18px instead
    return Transform.translate(
      offset: const Offset(0, -18), // move up 18px (same visual effect)
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kRose, kRoseDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: kRose.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LIMITED OFFER',
                  style: TextStyle(color: Colors.white70, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 6),
                const Text('20% OFF\nWedding Cakes',
                  style: TextStyle(color: kWhite, fontSize: 18,
                    fontWeight: FontWeight.bold, height: 1.3)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => BrowseScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kWhite, borderRadius: BorderRadius.circular(18)),
                    child: const Text('Order Now →',
                      style: TextStyle(color: kRose, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const Text('💍', style: TextStyle(fontSize: 56)),
        ],
      ),
      ), // closes Container
    );  // closes Transform.translate
  }

  Widget _buildCategories(BuildContext context) {
    const categories = [
      {'icon': '🎂', 'label': 'Birthday',  'color': 0xFFFFE8E0},
      {'icon': '💍', 'label': 'Wedding',   'color': 0xFFF5E4B8},
      {'icon': '🍫', 'label': 'Chocolate', 'color': 0xFFEDE0D4},
      {'icon': '🍓', 'label': 'Fruit',     'color': 0xFFE8F5E8},
      {'icon': '☕', 'label': 'Tiramisu',  'color': 0xFFF0EAE0},
      {'icon': '✨', 'label': 'Custom',    'color': 0xFFE8E0F5},
    ];
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => BrowseScreen(
                initialCategory: categories[i]['label'] as String))),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Color(categories[i]['color'] as int),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(categories[i]['icon'] as String,
                    style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(categories[i]['label'] as String,
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: kBrown)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestsellerRow(BuildContext context, Cake cake) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => CakeDetailScreen(cake: cake))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: cake.imageUrl, width: 70, height: 70, fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 70, height: 70, color: kRoseLight,
                  child: const Center(child: Text('🎂', style: TextStyle(fontSize: 28)))),
                errorWidget: (_, __, ___) => Container(
                  width: 70, height: 70, color: kRoseLight,
                  child: const Center(child: Text('🎂', style: TextStyle(fontSize: 28)))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cake.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15, color: kBrown)),
                      Text('\$${cake.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15, color: kRose)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(cake.description,
                    style: const TextStyle(fontSize: 12, color: kGray),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: kGold, size: 13),
                      const SizedBox(width: 3),
                      Text('${cake.rating}',
                        style: const TextStyle(
                          color: kGold, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('(${cake.reviewCount})',
                        style: const TextStyle(color: kGray, fontSize: 11)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kRoseLight, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Bestseller',
                          style: TextStyle(
                            color: kRose, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}