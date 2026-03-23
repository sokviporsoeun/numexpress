// ============================================================
// FILE: lib/screens/checkout_screen.dart
// PURPOSE: User picks delivery or pickup, enters address,
//          picks payment method, then places the order.
//          Order is saved to Firestore "orders" collection.
// ============================================================

import 'package:flutter/material.dart';
import 'package:numexpress/views/model/cart.dart';
import 'package:numexpress/views/theme/colors.dart';
import '../services/order_service.dart';
import '../widgets/my_button.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Which delivery method is selected
  String deliveryMethod = 'delivery'; // 'delivery' or 'pickup'

  // Which payment method is selected
  String paymentMethod  = 'khqr'; // 'khqr', 'cash', or 'bank'

  // Loading state for the place order button
  bool isLoading = false;

  // Text field controllers
  final addressCtrl = TextEditingController(text: '123 Street, BKK1, Phnom Penh');
  final phoneCtrl   = TextEditingController(text: '+855 12 345 678');
  final dateCtrl    = TextEditingController(text: 'Tomorrow');
  final timeCtrl    = TextEditingController(text: '2:00 PM - 4:00 PM');

  final OrderService orderService = OrderService();

  @override
  void dispose() {
    addressCtrl.dispose();
    phoneCtrl.dispose();
    dateCtrl.dispose();
    timeCtrl.dispose();
    super.dispose();
  }

  // Called when user taps "Place Order"
  void placeOrder() async {
    // Validate
    if (deliveryMethod == 'delivery' && addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Save order to Firestore
      String orderId = await orderService.placeOrder(
        items:           Cart.items,
        deliveryMethod:  deliveryMethod,
        paymentMethod:   paymentMethod,
        subtotal:        Cart.subtotal,
        deliveryFee:     deliveryMethod == 'delivery' ? Cart.deliveryFee : 0,
        total:           deliveryMethod == 'delivery'
                            ? Cart.grandTotal
                            : Cart.subtotal,
        deliveryAddress: deliveryMethod == 'delivery'
                            ? addressCtrl.text.trim() : null,
        phoneNum:     phoneCtrl.text.trim(),
        deliveryTime:    timeCtrl.text.trim(),
      );

      // Clear cart after order placed
      Cart.clear();

      if (!mounted) return;

      // Go to tracking screen with the new order ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:           const Text('Place Order',
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kBrown,
        foregroundColor: kCream,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Delivery Method ──────────────────
                const Text('Delivery Method',
                  style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.bold,
                    color:      kBrown,
                  )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _deliveryOption('delivery', '🚚', 'Delivery', '+\$3.50'),
                    const SizedBox(width: 12),
                    _deliveryOption('pickup',   '🏪', 'Pickup',   'Free'),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Address / Pickup info ────────────
                if (deliveryMethod == 'delivery')
                  _buildDeliveryForm()
                else
                  _buildPickupInfo(),

                const SizedBox(height: 20),

                // ── Payment Method ───────────────────
                const Text('Payment Method',
                  style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.bold,
                    color:      kBrown,
                  )),
                const SizedBox(height: 12),
                _paymentOption('khqr', '📱', 'KHQR / ABA Pay',    'Scan QR to pay'),
                _paymentOption('cash', '💵', 'Cash on Delivery',  'Pay when received'),
                _paymentOption('bank', '🏦', 'Bank Transfer',     'ABA, ACLEDA, Wing'),
                const SizedBox(height: 20),

                // ── Order Summary ────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        kWhite,
                    borderRadius: BorderRadius.circular(16),
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
                      const SizedBox(height: 12),
                      ...Cart.items.map((item) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.cake.name} (${item.size}) x${item.quantity}',
                                  style: const TextStyle(
                                    color: kGray, fontSize: 13),
                                )),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color:      kBrown,
                                  fontWeight: FontWeight.bold,
                                  fontSize:   13,
                                )),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: kGrayLight, height: 20),
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
                            '\$${(deliveryMethod == 'delivery' ? Cart.grandTotal : Cart.subtotal).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize:   18,
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

          // ── Place order button ───────────────────
          Positioned(
            bottom: 20,
            left:   16,
            right:  16,
            child: MyButton(
              label:     '✓  Place Order Now',
              isLoading: isLoading,
              onTap:     placeOrder,
            ),
          ),
        ],
      ),
    );
  }

  // ── Delivery/Pickup toggle button ──────────────────────────
  Widget _deliveryOption(
    String value, String icon, String label, String sub) {
    bool isActive = deliveryMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => deliveryMethod = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:        isActive ? kRose : kWhite,
            border:       Border.all(
              color: isActive ? kRose : kGrayLight, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:   14,
                  color: isActive ? kWhite : kBrown,
                )),
              Text(sub,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.white70 : kGray,
                )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Delivery form ──────────────────────────────────────────
  Widget _buildDeliveryForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏠 Delivery Details',
            style: TextStyle(
              fontSize:   15,
              fontWeight: FontWeight.bold,
              color:      kBrown,
            )),
          const SizedBox(height: 14),
          _inputRow('Address',       addressCtrl, Icons.location_on_outlined),
          const SizedBox(height: 10),
          _inputRow('Phone',         phoneCtrl,   Icons.phone_outlined),
          const SizedBox(height: 10),
          _inputRow('Delivery Date', dateCtrl,    Icons.calendar_today_outlined),
          const SizedBox(height: 10),
          _inputRow('Delivery Time', timeCtrl,    Icons.access_time),
        ],
      ),
    );
  }

  // ── Pickup info ────────────────────────────────────────────
  Widget _buildPickupInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏪 Pickup Details',
            style: TextStyle(
              fontSize:   15,
              fontWeight: FontWeight.bold,
              color:      kBrown,
            )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:        kGrayLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.store_outlined, color: kRose),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sweet Layers Bakery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, color: kBrown)),
                    Text('Street 178, BKK1, Phnom Penh',
                      style: TextStyle(color: kGray, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _inputRow('Pickup Date', dateCtrl, Icons.calendar_today_outlined),
          const SizedBox(height: 10),
          _inputRow('Pickup Time', timeCtrl, Icons.access_time),
        ],
      ),
    );
  }

  // ── Payment option ────────────────────────────────────────
  Widget _paymentOption(
    String value, String icon, String label, String sub) {
    bool isActive = paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => paymentMethod = value),
      child: AnimatedContainer(
        duration:   const Duration(milliseconds: 200),
        margin:     const EdgeInsets.only(bottom: 10),
        padding:    const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? kRoseLight : kWhite,
          border: Border.all(
            color: isActive ? kRose : kGrayLight, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color:      kBrown,
                    )),
                  Text(sub,
                    style: const TextStyle(
                      color: kGray, fontSize: 12)),
                ],
              ),
            ),
            // Radio circle
            Container(
              width:  22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? kRose : kGray, width: 2),
                color: isActive ? kRose : Colors.transparent,
              ),
              child: isActive
                  ? const Icon(Icons.check, color: kWhite, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable input row ─────────────────────────────────────
  Widget _inputRow(
    String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            fontSize: 11, color: kGray, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: kGray, size: 18),
            filled:     true,
            fillColor:  kGrayLight,
            border:     OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:   BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          style: const TextStyle(fontSize: 13, color: kBrown),
        ),
      ],
    );
  }
}