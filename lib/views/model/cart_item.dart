// ============================================================
// FILE: lib/models/cart_item.dart
// PURPOSE: One item in the shopping cart
//          This is NOT saved to Firestore yet - only in memory
//          It gets saved when the user places an order
// ============================================================

import 'cake.dart';

class CartItem {
  final Cake cake;       // which cake
  final String size;     // "Small", "Medium", or "Large"
  final String flavor;   // chosen flavor
  final String message;  // custom message on cake (optional)
  int quantity;          // how many

  CartItem({
    required this.cake,
    required this.size,
    required this.flavor,
    this.message = '',
    this.quantity = 1,
  });

  // Extra cost based on size
  double get sizeExtra {
    if (size == 'Large')  return 18.0;
    if (size == 'Medium') return 8.0;
    return 0.0; // Small = no extra
  }

  // Price for one cake
  double get unitPrice => cake.price + sizeExtra;

  // Price for all (quantity * unitPrice)
  double get totalPrice => unitPrice * quantity;

  // Convert to a simple Map for saving inside an order in Firestore
  Map<String, dynamic> toMap() {
    return {
      'cakeId':    cake.id,
      'cakeName':  cake.name,
      'imageUrl':  cake.imageUrl,
      'size':      size,
      'flavor':    flavor,
      'message':   message,
      'quantity':  quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}