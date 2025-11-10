// lib/Product.dart

class Product {
  // Fields required by the exercise
  final String? id; // Firestore document ID
  final String name;
  final int quantity;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  // Helper for Requirement 4: Calculate stock value
  double get stockValue => quantity * price;

  // 1. Convert Product object to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      // 'id' is intentionally omitted as it's the document ID in Firestore
    };
  }

  // 2. Convert a Firestore Document Snapshot/Map to a Product object
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String,
      // Firestore stores numbers as either int or double, so we ensure int for quantity
      quantity: (map['quantity'] as num).toInt(),
      // Firestore stores numbers as either int or double, so we ensure double for price
      price: (map['price'] as num).toDouble(), 
    );
  }
}