// ============================================================
// FILE: lib/services/order_service.dart
// PURPOSE: Save orders to Firestore and get order history
//
// Firestore collection: "orders"
// Each order document looks like:
// {
//   userId: "abc123",
//   orderNumber: "CK-1234",
//   status: "preparing",
//   deliveryMethod: "delivery",
//   paymentMethod: "khqr",
//   deliveryAddress: "Street 178...",
//   phoneNumber: "+855...",
//   deliveryTime: "2:00 PM",
//   subtotal: 28.0,
//   deliveryFee: 3.5,
//   total: 31.5,
//   createdAt: Timestamp,
//   items: [ { cakeId, cakeName, size, flavor, ... } ]
// }
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numexpress/views/model/cart_item.dart';


class OrderService {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  // ----------------------------------------------------------
  // PLACE ORDER - save to Firestore
  // Returns the new order ID so we can show tracking screen
  // ----------------------------------------------------------
  Future<String> placeOrder({
    required List<CartItem> items,
    required String deliveryMethod, // "delivery" or "pickup"
    required String paymentMethod,  // "cash", "khqr", "bank"
    required double subtotal,
    required double deliveryFee,
    required double total,
    String? deliveryAddress,
    String? phoneNum,
    String? deliveryTime,
  }) async {
    // Get the logged in user's ID
    String userId = _auth.currentUser?.uid ?? 'guest';

    // Make a simple order number like CK-5823
    String orderNumber = 'CK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Convert cart items to a list of maps for Firestore
    List<Map<String, dynamic>> itemsList = items.map((item) => item.toMap()).toList();

    // Save to Firestore
    DocumentReference ref = await _db.collection('orders').add({
      'userId':          userId,
      'orderNumber':     orderNumber,
      'status':          'pending',       // starts as pending
      'deliveryMethod':  deliveryMethod,
      'paymentMethod':   paymentMethod,
      'deliveryAddress': deliveryAddress,
      'phoneNum':     phoneNum,
      'deliveryTime':    deliveryTime,
      'subtotal':        subtotal,
      'deliveryFee':     deliveryFee,
      'total':           total,
      'items':           itemsList,
      'createdAt':       FieldValue.serverTimestamp(), // Firebase sets the time
    });

    return ref.id; // return the new document ID
  }

  // ----------------------------------------------------------
  // GET MY ORDERS - stream for order history screen
  // Shows orders for the currently logged-in user
  // ----------------------------------------------------------
  Stream<List<Map<String, dynamic>>> getMyOrders() {
    String userId = _auth.currentUser?.uid ?? '';

    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true) // newest first
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Include the document ID in the map
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // ----------------------------------------------------------
  // WATCH ONE ORDER - for live tracking
  // The status updates in real-time when seller changes it
  // ----------------------------------------------------------
  Stream<Map<String, dynamic>?> watchOrder(String orderId) {
    return _db
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        });
  }
}