// ============================================================
// FILE: lib/screens/cart_screen.dart
// PURPOSE: Show all items in cart with totals
//          User can change quantity, remove items, then checkout
//          Cart data is stored in the Cart class (not Firestore yet)
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:numexpress/views/model/cart.dart';
import 'package:numexpress/views/theme/colors.dart';
import '../widgets/my_button.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:           const Text('My Cart 🛒',
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kBrown,
        foregroundColor: kCream,
        automaticallyImplyLeading: false,
      ),
      body: Cart.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartList(context),
    );
  }

  // Show when cart has no items
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 70)),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize:   20,
              fontWeight: FontWeight.bold,
              color:      kBrown,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse our cakes and add your favorites!',
            style: TextStyle(color: kGray),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: MyButton(
              label: 'Browse Cakes 🎂',
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // Show list of items when cart has items
  Widget _buildCartList(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Cart items ───────────────────────
              ...List.generate(Cart.items.length, (index) {
                var item = Cart.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:        kWhite,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color:     Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cake image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: item.cake.imageUrl,
                          width:    65,
                          height:   65,
                          fit:      BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 65, height: 65,
                            color: kRoseLight,
                            child: const Center(
                              child: Text('🎂', style: TextStyle(fontSize: 26))),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 65, height: 65,
                            color: kRoseLight,
                            child: const Center(
                              child: Text('🎂', style: TextStyle(fontSize: 26))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.cake.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:   14,
                                    color:      kBrown,
                                  ),
                                ),
                                // Remove button
                                GestureDetector(
                                  onTap: () {
                                    setState(() => Cart.removeItem(index));
                                  },
                                  child: const Icon(
                                    Icons.close, color: kGray, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${item.size} • ${item.flavor}',
                              style: const TextStyle(
                                color: kGray, fontSize: 12),
                            ),
                            // Show cake message if added
                            if (item.message.isNotEmpty)
                              Text(
                                '"${item.message}"',
                                style: const TextStyle(
                                  color:      kRose,
                                  fontSize:   11,
                                  fontStyle:  FontStyle.italic,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color:      kRose,
                                    fontWeight: FontWeight.bold,
                                    fontSize:   15,
                                  ),
                                ),
                                // Quantity controls
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() =>
                                        Cart.decreaseQuantity(index)),
                                      child: Container(
                                        width:  28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color:        kGrayLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.remove, color: kRose, size: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:      kBrown,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() =>
                                        Cart.increaseQuantity(index)),
                                      child: Container(
                                        width:  28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color:        kRoseLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.add, color: kRose, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // ── Order summary ────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color:        kWhite,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary',
                      style: TextStyle(
                        fontSize:   16,
                        fontWeight: FontWeight.bold,
                        color:      kBrown,
                      )),
                    const SizedBox(height: 14),
                    _summaryRow('Subtotal',     '\$${Cart.subtotal.toStringAsFixed(2)}'),
                    _summaryRow('Delivery Fee', '\$${Cart.deliveryFee.toStringAsFixed(2)}'),
                    _summaryRow('Discount',     '\$0.00'),
                    const Divider(color: kGrayLight, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                          style: TextStyle(
                            fontSize:   18,
                            fontWeight: FontWeight.bold,
                            color:      kBrown,
                          )),
                        Text(
                          '\$${Cart.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize:   20,
                            fontWeight: FontWeight.bold,
                            color:      kRose,
                          )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Checkout button fixed at bottom ──────
        Positioned(
          bottom: 20,
          left:   16,
          right:  16,
          child: MyButton(
            label: 'Proceed to Order →',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kGray, fontSize: 14)),
          Text(value, style: const TextStyle(color: kBrown, fontSize: 14)),
        ],
      ),
    );
  }
}