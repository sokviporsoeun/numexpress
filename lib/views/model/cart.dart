// ============================================================
// FILE: lib/models/cart.dart
// PURPOSE: A simple global cart - just a list of CartItems
//          We use a simple static list so all screens share it
//          No Provider or complex state management needed
// ============================================================

import 'cart_item.dart';
import 'cake.dart';

// This is our global cart - one list shared across all screens
class Cart {
  // Static list so all screens see the same cart
  static List<CartItem> items = [];

  // Add a cake to cart
  // If the same cake+size+flavor exists, increase quantity instead
  static void addItem({
    required Cake cake,
    required String size,
    required String flavor,
    String message = '',
    int quantity = 1,
  }) {
    // Check if same item already exists
    for (var item in items) {
      if (item.cake.id == cake.id &&
          item.size == size &&
          item.flavor == flavor) {
        item.quantity += quantity; // just increase quantity
        return;
      }
    }
    // Not found - add new item
    items.add(CartItem(
      cake:     cake,
      size:     size,
      flavor:   flavor,
      message:  message,
      quantity: quantity,
    ));
  }

  // Remove item by its position in the list
  static void removeItem(int index) {
    items.removeAt(index);
  }

  // Increase quantity of one item
  static void increaseQuantity(int index) {
    items[index].quantity++;
  }

  // Decrease quantity - if it reaches 0, remove the item
  static void decreaseQuantity(int index) {
    if (items[index].quantity > 1) {
      items[index].quantity--;
    } else {
      items.removeAt(index);
    }
  }

  // Total of all items (before delivery fee)
  static double get subtotal {
    double total = 0;
    for (var item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  // Delivery fee - flat rate
  static double get deliveryFee => 3.5;

  // Grand total
  static double get grandTotal => subtotal + deliveryFee;

  // How many items total (for the badge on cart icon)
  static int get itemCount {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  // Is the cart empty?
  static bool get isEmpty => items.isEmpty;

  // Empty the cart after order is placed
  static void clear() {
    items.clear();
  }
}