// ============================================================
// FILE: lib/screens/order_tracking_screen.dart
// PURPOSE: Shown after placing an order
//          Reads order status from Firestore in real-time
//          Status updates automatically when seller changes it
// ============================================================

import 'package:flutter/material.dart';
import 'package:numexpress/views/theme/colors.dart';

import '../services/order_service.dart';
import '../widgets/my_button.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId; // The Firestore document ID of the order

  const OrderTrackingScreen({super.key, required this.orderId});

  // Map status string to step number (0-4)
  int statusToStep(String status) {
    switch (status) {
      case 'pending':         return 0;
      case 'confirmed':       return 0;
      case 'preparing':       return 1;
      case 'packing':         return 2;
      case 'outForDelivery':
      case 'readyForPickup':  return 3;
      case 'delivered':
      case 'pickedUp':        return 4;
      default:                return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();

    return Scaffold(
      body: StreamBuilder<Map<String, dynamic>?>(
        // Watch this order in real-time - updates when seller changes status
        stream: orderService.watchOrder(orderId),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kRose));
          }

          Map<String, dynamic>? order = snapshot.data;
          String status  = order?['status']         ?? 'pending';
          String orderNo = order?['orderNumber']    ?? '...';
          bool isDelivery = order?['deliveryMethod'] == 'delivery';
          int   step     = statusToStep(status);

          // Steps for delivery
          List<Map<String, String>> deliverySteps = [
            {'icon': '✅', 'label': 'Order Received'},
            {'icon': '👩‍🍳', 'label': 'Preparing Cake'},
            {'icon': '📦', 'label': 'Packing'},
            {'icon': '🚚', 'label': 'Out for Delivery'},
            {'icon': '🏠', 'label': 'Delivered'},
          ];

          // Steps for pickup
          List<Map<String, String>> pickupSteps = [
            {'icon': '✅', 'label': 'Order Received'},
            {'icon': '👩‍🍳', 'label': 'Preparing Cake'},
            {'icon': '📦', 'label': 'Packing'},
            {'icon': '🏪', 'label': 'Ready for Pickup'},
            {'icon': '✅', 'label': 'Picked Up'},
          ];

          List<Map<String, String>> steps =
            isDelivery ? deliverySteps : pickupSteps;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            child: Column(
              children: [

                // ── Success icon ─────────────────────
                Container(
                  width:  100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('✅', style: TextStyle(fontSize: 50))),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Order Placed!',
                  style: TextStyle(
                    fontSize:   26,
                    fontWeight: FontWeight.bold,
                    color:      kBrown,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order #$orderNo',
                  style: const TextStyle(
                    color: kBrown, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isDelivery
                      ? 'Your cake is being prepared with love 🎂\nEstimated delivery: 2–3 hours'
                      : 'Your cake is being prepared 🎂\nWe will notify you when ready for pickup',
                  style: const TextStyle(color: kGray, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // ── Live status tracker ──────────────
                Container(
                  padding: const EdgeInsets.all(20),
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
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize:   16,
                          fontWeight: FontWeight.bold,
                          color:      kBrown,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Each step row
                      ...List.generate(steps.length, (i) {
                        bool isDone = i <= step;
                        bool isLast = i == steps.length - 1;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon column with connecting line
                            Column(
                              children: [
                                Container(
                                  width:  38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? const Color(0xFFE8F5E8)
                                        : kGrayLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      steps[i]['icon']!,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                // Connecting line (not on last step)
                                if (!isLast)
                                  Container(
                                    width:  2,
                                    height: 28,
                                    color:  isDone
                                        ? kGreen.withOpacity(0.3)
                                        : kGrayLight,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // Step label
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Text(
                                    steps[i]['label']!,
                                    style: TextStyle(
                                      color:      isDone ? kBrown : kGray,
                                      fontWeight: isDone
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (isDone && !isLast) ...[
                                    const SizedBox(width: 8),
                                    const Text('✓',
                                      style: TextStyle(
                                        color: kGreen,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Order details ────────────────────
                if (order != null)
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
                        const Text('Order Details',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.bold,
                            color:      kBrown,
                          )),
                        const SizedBox(height: 12),
                        _detailRow('Method',
                          isDelivery ? '🚚 Delivery' : '🏪 Pickup'),
                        _detailRow('Payment',
                          order['paymentMethod'] == 'khqr'
                              ? '📱 KHQR'
                              : order['paymentMethod'] == 'cash'
                                  ? '💵 Cash'
                                  : '🏦 Bank Transfer'),
                        if (order['deliveryAddress'] != null)
                          _detailRow('Address', order['deliveryAddress']),
                        _detailRow('Total',
                          '\$${(order['total'] ?? 0).toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // ── Back to home button ──────────────
                MyButton(
                  label: '🏠  Back to Home',
                  onTap: () => Navigator.popUntil(
                    context, (route) => route.isFirst),
                ),
                const SizedBox(height: 14),

                // Rate button
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Rate your experience ⭐',
                    style: TextStyle(
                      color:      kRose,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kGray, fontSize: 13)),
          Text(value,
            style: const TextStyle(
              color:      kBrown,
              fontWeight: FontWeight.bold,
              fontSize:   13,
            )),
        ],
      ),
    );
  }
}