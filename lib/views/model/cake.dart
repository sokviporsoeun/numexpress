// ============================================================
// FILE: lib/models/cake.dart
// PURPOSE: Represents one cake from Firestore
//
// Firestore collection: "cakes"
// Each document looks like this:
// {
//   name: "Velvet Dream",
//   category: "Birthday",
//   price: 28,
//   imageUrl: "https://...",
//   description: "Rich red velvet cake",
//   rating: 4.9,
//   reviewCount: 124,
//   flavors: ["Red Velvet", "Vanilla"],
//   isBestseller: true,
//   isAvailable: true
// }
// ============================================================

class Cake {
  final String id;          // Firestore document ID
  final String name;        // e.g. "Velvet Dream"
  final String category;    // e.g. "Birthday"
  final double price;       // base price
  final String imageUrl;    // link to cake photo
  final String description; // short description
  final double rating;      // 0.0 - 5.0
  final int reviewCount;    // number of reviews
  final List<String> flavors; // available flavors
  final bool isBestseller;  // show HOT badge
  final bool isAvailable;   // hide if false

  Cake({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.flavors,
    required this.isBestseller,
    required this.isAvailable,
  });

  // This factory reads a Firestore document and creates a Cake object
  factory Cake.fromFirestore(Map<String, dynamic> data, String id) {
    return Cake(
      id:           id,
      name:         data['name']         ?? 'Unknown Cake',
      category:     data['category']     ?? 'Other',
      price:        (data['price']       ?? 0).toDouble(),
      imageUrl:     data['imageUrl']     ?? '',
      description:  data['description']  ?? '',
      rating:       (data['rating']      ?? 0.0).toDouble(),
      reviewCount:  data['reviewCount']  ?? 0,
      // Firestore arrays become Dart lists
      flavors:      List<String>.from(data['flavors'] ?? []),
      isBestseller: data['isBestseller'] ?? false,
      isAvailable:  data['isAvailable']  ?? true,
    );
  }
}