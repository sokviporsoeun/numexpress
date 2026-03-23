// ============================================================
// FILE: lib/screens/cake_detail_screen.dart
// PURPOSE: Shows full cake info + customization options
//          User picks size, flavor, adds message and qty
//          Then taps "Add to Cart" to go to cart screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:numexpress/views/model/cake.dart';
import 'package:numexpress/views/model/cart.dart';
import 'package:numexpress/views/theme/colors.dart';

import '../widgets/my_button.dart';

class CakeDetailScreen extends StatefulWidget {
  final Cake cake;

  const CakeDetailScreen({super.key, required this.cake});

  @override
  State<CakeDetailScreen> createState() => _CakeDetailScreenState();
}

class _CakeDetailScreenState extends State<CakeDetailScreen> {
  // Default selections
  String selectedSize   = 'Medium';
  String selectedFlavor = '';
  int quantity          = 1;

  final TextEditingController messageCtrl = TextEditingController();

  // Size options with extra cost
  final List<Map<String, dynamic>> sizes = [
    {'label': 'Small',  'serves': '6-8',   'extra': 0},
    {'label': 'Medium', 'serves': '10-15', 'extra': 8},
    {'label': 'Large',  'serves': '20-30', 'extra': 18},
  ];

  @override
  void initState() {
    super.initState();
    // Set default flavor to first available
    if (widget.cake.flavors.isNotEmpty) {
      selectedFlavor = widget.cake.flavors.first;
    }
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    super.dispose();
  }

  // Get extra cost based on size
  int get sizeExtra {
    for (var size in sizes) {
      if (size['label'] == selectedSize) return size['extra'] as int;
    }
    return 0;
  }

  // Unit price = base price + size extra
  double get unitPrice => widget.cake.price + sizeExtra;

  // Total = unit price x quantity
  double get totalPrice => unitPrice * quantity;

  // Add to cart and go back
  void addToCart(BuildContext context) {
    Cart.addItem(
      cake:     widget.cake,
      size:     selectedSize,
      flavor:   selectedFlavor,
      message:  messageCtrl.text.trim(),
      quantity: quantity,
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.cake.name} added to cart! 🎂'),
        backgroundColor: kRose,
        behavior:        SnackBarBehavior.floating,
        duration:        const Duration(seconds: 2),
      ),
    );

    // Go back to previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ── Scrollable content ─────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Cake image with back button ──────
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.cake.imageUrl,
                      height:   280,
                      width:    double.infinity,
                      fit:      BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 280,
                        color:  kRoseLight,
                        child:  const Center(
                          child: Text('🎂', style: TextStyle(fontSize: 80)),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 280,
                        color:  kRoseLight,
                        child:  const Center(
                          child: Text('🎂', style: TextStyle(fontSize: 80)),
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top:  48,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:        Colors.white.withOpacity(0.9),
                            shape:        BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                            size: 18, color: kBrown),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top:   48,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border,
                          color: kRose, size: 22),
                      ),
                    ),
                  ],
                ),

                // ── White card with details ──────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color:        kWhite,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Name + price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.cake.name,
                              style: const TextStyle(
                                fontSize:   22,
                                fontWeight: FontWeight.bold,
                                color:      kBrown,
                              ),
                            ),
                          ),
                          Text(
                            '\$${unitPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize:   22,
                              fontWeight: FontWeight.bold,
                              color:      kRose,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating and category
                      Row(
                        children: [
                          const Icon(Icons.star, color: kGold, size: 15),
                          const SizedBox(width: 4),
                          Text('${widget.cake.rating}',
                            style: const TextStyle(
                              color:      kGold,
                              fontWeight: FontWeight.bold,
                              fontSize:   13)),
                          const SizedBox(width: 4),
                          Text('(${widget.cake.reviewCount} reviews)',
                            style: const TextStyle(color: kGray, fontSize: 12)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:        kGrayLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.cake.category,
                              style: const TextStyle(
                                fontSize:   11,
                                fontWeight: FontWeight.bold,
                                color:      kBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description
                      Text(
                        widget.cake.description,
                        style: const TextStyle(
                          color: kGray, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      const Divider(color: kGrayLight),
                      const SizedBox(height: 16),

                      // ── Size picker ──────────────
                      const Text('Size',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: kBrown)),
                      const SizedBox(height: 12),
                      Row(
                        children: sizes.map((size) {
                          bool isActive = selectedSize == size['label'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                setState(() => selectedSize = size['label'] as String),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color:        isActive ? kRose : kGrayLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      size['label'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:   13,
                                        color: isActive ? kWhite : kBrown,
                                      ),
                                    ),
                                    Text(
                                      'Serves ${size['serves']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isActive
                                            ? Colors.white70 : kGray,
                                      ),
                                    ),
                                    if (size['extra'] as int > 0)
                                      Text(
                                        '+\$${size['extra']}',
                                        style: TextStyle(
                                          fontSize:   11,
                                          fontWeight: FontWeight.bold,
                                          color: isActive ? kWhite : kRose,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // ── Flavor picker ────────────
                      if (widget.cake.flavors.isNotEmpty) ...[
                        const Text('Flavor',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: kBrown)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing:   8,
                          runSpacing: 8,
                          children: widget.cake.flavors.map((flavor) {
                            bool isActive = selectedFlavor == flavor;
                            return GestureDetector(
                              onTap: () =>
                                setState(() => selectedFlavor = flavor),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color:        isActive ? kBrown : kGrayLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  flavor,
                                  style: TextStyle(
                                    color:      isActive ? kCream : kBrown,
                                    fontWeight: FontWeight.bold,
                                    fontSize:   13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Message field ────────────
                      const Text('Cake Message (optional)',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: kBrown)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: messageCtrl,
                        decoration: InputDecoration(
                          hintText:  'e.g. Happy Birthday Mama! 🎉',
                          hintStyle: const TextStyle(color: kGray),
                          prefixIcon: const Icon(
                            Icons.cake_outlined, color: kGray),
                          filled:    true,
                          fillColor: kGrayLight,
                          border:    OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:   BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Quantity picker ──────────
                      Row(
                        children: [
                          const Text('Quantity',
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: kBrown)),
                          const SizedBox(width: 20),
                          // Minus button
                          GestureDetector(
                            onTap: () {
                              if (quantity > 1) {
                                setState(() => quantity--);
                              }
                            },
                            child: Container(
                              width:  36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:        kGrayLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.remove, color: kRose),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize:   18,
                              fontWeight: FontWeight.bold,
                              color:      kBrown,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Plus button
                          GestureDetector(
                            onTap: () => setState(() => quantity++),
                            child: Container(
                              width:  36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:        kRoseLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add, color: kRose),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '\$${totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize:   22,
                              fontWeight: FontWeight.bold,
                              color:      kRose,
                            ),
                          ),
                        ],
                      ),

                      // Extra space so content doesn't hide behind button
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Add to cart button (fixed at bottom) ───
          Positioned(
            bottom: 20,
            left:   20,
            right:  20,
            child: MyButton(
              label: '🛒  Add to Cart — \$${totalPrice.toStringAsFixed(0)}',
              onTap: () => addToCart(context),
            ),
          ),
        ],
      ),
    );
  }
}