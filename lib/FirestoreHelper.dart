// lib/FirestoreHelper.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'Product.dart';

class FirestoreHelper {
  // Singleton pattern for a single instance
  static final FirestoreHelper instance = FirestoreHelper._privateConstructor();

  FirestoreHelper._privateConstructor();

  // Reference to the 'products' collection (Requirement 1)
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Method to store a product (Requirement 2: "Save" button logic)
  Future<void> insertProduct(Product product) async {
    // Add will auto-generate the document ID (Requirement 1: id)
    await productsCollection.add(product.toMap());
  }

  // Method to fetch and display live Firestore data (Requirement 3)
  Stream<List<Product>> getAllProducts() {
    return productsCollection.snapshots().map((snapshot) {
      // Map the DocumentSnapshot to a list of Product objects
      return snapshot.docs.map((doc) {
        // Use the Product.fromMap factory constructor
        // Pass the doc.id as the Product's id field
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}