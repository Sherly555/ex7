// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Product.dart';
import 'FirestoreHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  // Initialize Flutter Widgets and Firebase connection
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Assumes Firebase is set up correctly
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Inventory Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InventoryScreen(),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Text Controllers for the form (Requirement 2)
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Function to save the product to Firestore
  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      // Create a new Product object
      final newProduct = Product(
        name: _nameController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
      );

      // Call the helper to insert the product
      await FirestoreHelper.instance.insertProduct(newProduct);

      // Clear the form fields
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud-Based Product Inventory Tracker'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 1. Product Input Form (Requirement 2) ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (value) => value!.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) => int.tryParse(value!) == null ? 'Enter valid number' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) => double.tryParse(value!) == null ? 'Enter valid price' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: const Text('Save Product'), // Requirement 2: "Save" button
                  ),
                ],
              ),
            ),

            const Divider(height: 32),

            // --- 2. Live Product List (Requirement 3) ---
            Expanded(
              // StreamBuilder fetches real-time updates from Firestore
              child: StreamBuilder<List<Product>>(
                stream: FirestoreHelper.instance.getAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products in inventory.'));
                  }

                  final products = snapshot.data!;
                  // Calculate total stock value for the footer (Requirement 4)
                  final totalStockValue = products.fold(
                    0.0,
                    (sum, item) => sum + item.stockValue,
                  );

                  return Column(
                    children: [
                      Expanded(
                        // Display all saved products in a ListView
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            // Check for Low Stock Condition (Requirement 5)
                            final isLowStock = product.quantity < 5;

                            return ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                'Qty: ${product.quantity} | Price: \$${product.price.toStringAsFixed(2)} | Value: \$${product.stockValue.toStringAsFixed(2)}',
                              ),
                              trailing: isLowStock
                                  ? const Text(
                                      'Low Stock!', // Requirement 5: Low Stock Warning
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                      
                      const Divider(),

                      // --- 3. Total Stock Value Display (Requirement 4) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Total Stock Value = \$${totalStockValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}