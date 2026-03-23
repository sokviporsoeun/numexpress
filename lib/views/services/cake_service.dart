// ============================================================
// FILE: lib/services/cake_service.dart
// PURPOSE: Get cakes from Firestore "cakes" collection
//
// Make sure your Firestore has a "cakes" collection
// with documents that have these fields:
//   name, category, price, imageUrl, description,
//   rating, reviewCount, flavors (array),
//   isBestseller (bool), isAvailable (bool)
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numexpress/views/model/cake.dart';


class CakeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------------------------
  // GET ALL CAKES - returns a stream so UI updates automatically
  // This is a real-time listener - when you add a cake in
  // Firestore console, it appears in the app immediately
  // ----------------------------------------------------------
  Stream<List<Cake>> getAllCakes() {
    return _db
        .collection('cakes')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          // Convert each Firestore document to a Cake object
          return snapshot.docs.map((doc) {
            return Cake.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ----------------------------------------------------------
  // GET CAKES BY CATEGORY - for filtering
  // ----------------------------------------------------------
  Stream<List<Cake>> getCakesByCategory(String category) {
    return _db
        .collection('cakes')
        .where('isAvailable', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Cake.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ----------------------------------------------------------
  // GET BESTSELLERS - for the home screen
  // ----------------------------------------------------------
  Stream<List<Cake>> getBestsellers() {
    return _db
        .collection('cakes')
        .where('isAvailable',  isEqualTo: true)
        .where('isBestseller', isEqualTo: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Cake.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }
}