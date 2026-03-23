// ============================================================
// FILE: lib/screens/orders_screen.dart
// PURPOSE: Shows all past orders for the logged-in user
//          Reads from Firestore "orders" collection in real-time
//          User can tap an order to see live tracking
// ============================================================

import 'package:flutter/material.dart';
import 'package:numexpress/views/theme/colors.dart';

import '../services/order_service.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  // Convert status string to a nice label
  String statusLabel(String status) {
    switch (status) {
      case 'pending':         return 'Order Placed';
      case 'confirmed':       return 'Confirmed';
      case 'preparing':       return 'Preparing';
      case 'packing':         return 'Packing';
      case 'outForDelivery':  return 'Out for Delivery';
      case 'readyForPickup':  return 'Ready for Pickup';
      case 'delivered':       return 'Delivered';
      case 'pickedUp':        return 'Picked Up';
      case 'cancelled':       return 'Cancelled';
      default:                return 'Processing';
    }
  }

  // Color for each status badge
  Color statusColor(String status) {
    if (status == 'delivered' || status == 'pickedUp') return kGreen;
    if (status == 'cancelled') return kRoseDark;
    return kGold;
  }

  // Background color for each status badge
  Color statusBgColor(String status) {
    if (status == 'delivered' || status == 'pickedUp') {
      return const Color(0xFFE8F5E8);
    }
    if (status == 'cancelled') return kRoseLight;
    return kGoldLight;
  }

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders 📦',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:           kBrown,
        foregroundColor:           kCream,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Real-time stream — updates when seller changes status
        stream: orderService.getMyOrders(),
        builder: (context, snapshot) {

          // Still loading from Firestore
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kRose),
            );
          }

          // Error from Firestore
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load orders.',
                style: TextStyle(color: kGray),
              ),
            );
          }

          List<Map<String, dynamic>> orders = snapshot.data ?? [];

          // No orders yet
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📦', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize:   20,
                      fontWeight: FontWeight.bold,
                      color:      kBrown,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Place your first cake order!',
                    style: TextStyle(color: kGray),
                  ),
                ],
              ),
            );
          }

          // Show list of orders
          return ListView.separated(
            padding:          const EdgeInsets.all(16),
            itemCount:        orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              Map<String, dynamic> order = orders[index];
              String status      = order['status']      ?? 'pending';
              String orderNumber = order['orderNumber'] ?? '---';
              double total       = (order['total']      ?? 0).toDouble();
              String method      = order['deliveryMethod'] ?? 'delivery';

              // Format date nicely
              String dateStr = 'Just now';
              if (order['createdAt'] != null) {
                try {
                  DateTime date = order['createdAt'].toDate();
                  dateStr = '${date.day}/${date.month}/${date.year}';
                } catch (_) {}
              }

              return GestureDetector(
                // Tap to see live tracking
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      orderId: order['id'] ?? '',
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        kWhite,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color:     Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset:    const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      // ── Top row: order number + status badge ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #$orderNumber',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:   15,
                                  color:      kBrown,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color:   kGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color:        statusBgColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel(status),
                              style: TextStyle(
                                color:      statusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize:   12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: kGrayLight, height: 1),
                      const SizedBox(height: 12),

                      // ── Bottom row: delivery method + total + reorder ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Delivery method icon
                          Row(
                            children: [
                              Icon(
                                method == 'delivery'
                                    ? Icons.delivery_dining_outlined
                                    : Icons.store_outlined,
                                color: kGray,
                                size:  16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                method == 'delivery' ? 'Delivery' : 'Pickup',
                                style: const TextStyle(
                                  color:   kGray,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          // Total price
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color:      kRose,
                              fontWeight: FontWeight.bold,
                              fontSize:   15,
                            ),
                          ),

                          // Reorder button
                          OutlinedButton(
                            onPressed: () {
                              // TODO: implement reorder
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reorder coming soon!'),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kRose,
                              side:    const BorderSide(color: kRose),
                              shape:   RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            ),
                            child: const Text(
                              'Reorder',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:   13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}