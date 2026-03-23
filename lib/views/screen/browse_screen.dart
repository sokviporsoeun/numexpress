// ============================================================
// FILE: lib/screens/browse_screen.dart
// PURPOSE: Shows all cakes with category filter
//          User can search by name and filter by category
//          Cakes come from Firestore in real-time
// ============================================================

import 'package:flutter/material.dart';
import 'package:numexpress/views/model/cake.dart';
import 'package:numexpress/views/theme/colors.dart';
import '../services/cake_service.dart';

import '../widgets/cake_card.dart';
import 'cake_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  // Optional - if set, will pre-select this category
  final String? initialCategory;

  const BrowseScreen({super.key, this.initialCategory});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final CakeService cakeService   = CakeService();
  final TextEditingController searchCtrl = TextEditingController();

  String activeCategory = 'All';
  String searchText     = '';

  // All available categories
  final List<String> categories = [
    'All', 'Birthday', 'Wedding', 'Chocolate', 'Fruit', 'Tiramisu', 'Custom',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial category if provided from home screen
    if (widget.initialCategory != null) {
      activeCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // Filter cakes by search text (client-side filtering)
  List<Cake> filterBySearch(List<Cake> cakes) {
    if (searchText.isEmpty) return cakes;
    String query = searchText.toLowerCase();
    return cakes.where((cake) {
      return cake.name.toLowerCase().contains(query) ||
             cake.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // ── Header with search ───────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            color: kBrown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button (if navigated from home)
                if (Navigator.canPop(context))
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: kCream),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Our Cakes 🎂',
                  style: TextStyle(
                    color:      kCream,
                    fontSize:   24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                // Search field
                TextField(
                  controller: searchCtrl,
                  onChanged: (value) => setState(() => searchText = value),
                  style: const TextStyle(color: kCream),
                  decoration: InputDecoration(
                    hintText:    'Search cakes...',
                    hintStyle:   const TextStyle(color: Colors.white38),
                    prefixIcon:  const Icon(Icons.search, color: Colors.white38),
                    filled:      true,
                    fillColor:   Colors.white.withOpacity(0.15),
                    border:      OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:   BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),

          // ── Category filter chips ───────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection:  Axis.horizontal,
              padding:          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount:        categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                bool isActive = activeCategory == categories[i];
                return GestureDetector(
                  onTap: () => setState(() => activeCategory = categories[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color:        isActive ? kRose : kWhite,
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(
                        color: isActive ? kRose : kGrayLight,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      categories[i],
                      style: TextStyle(
                        color:      isActive ? kWhite : kBrown,
                        fontWeight: FontWeight.bold,
                        fontSize:   13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Cake grid ──────────────────────────────
          Expanded(
            child: StreamBuilder<List<Cake>>(
              // Switch stream based on selected category
              stream: activeCategory == 'All'
                  ? cakeService.getAllCakes()
                  : cakeService.getCakesByCategory(activeCategory),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kRose));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading cakes'));
                }

                // Apply search filter on top of category filter
                List<Cake> cakes = filterBySearch(snapshot.data ?? []);

                if (cakes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎂', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text('No cakes found',
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: kBrown)),
                        SizedBox(height: 6),
                        Text('Try a different category',
                          style: TextStyle(color: kGray)),
                      ],
                    ),
                  );
                }

                // 2-column grid of cake cards
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   2,
                    mainAxisSpacing:  14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.70,
                  ),
                  itemCount:   cakes.length,
                  itemBuilder: (context, i) {
                    return CakeCard(
                      cake:  cakes[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CakeDetailScreen(cake: cakes[i]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}