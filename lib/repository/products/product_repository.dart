import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFeatured;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isFeatured = false,
    this.isAvailable = true,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int) 
          ? (data['price'] as int).toDouble() 
          : (data['price'] ?? 0.0),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  // For demo purposes - create dummy products when Firestore is not available
  static List<Product> getDummyProducts() {
    return [
      Product(
        id: '1',
        name: 'Fresh Apples',
        description: 'Fresh red apples from local farms',
        price: 2.99,
        imageUrl: 'assets/images/apple.png',
        category: 'Fruits',
        isFeatured: true,
      ),
      Product(
        id: '2',
        name: 'Organic Milk',
        description: 'Organic full-cream milk',
        price: 3.49,
        imageUrl: 'assets/images/milk.png',
        category: 'Dairy',
        isFeatured: true,
      ),
      Product(
        id: '3',
        name: 'Whole Wheat Bread',
        description: 'Freshly baked whole wheat bread',
        price: 4.99,
        imageUrl: 'assets/images/bread.png',
        category: 'Bakery',
        isFeatured: true,
      ),
      Product(
        id: '4',
        name: 'Fresh Tomatoes',
        description: 'Ripe and juicy tomatoes',
        price: 1.99,
        imageUrl: 'assets/images/tomato.png',
        category: 'Vegetables',
      ),
      Product(
        id: '5',
        name: 'Banana Bunch',
        description: 'Sweet and ripe bananas',
        price: 2.49,
        imageUrl: 'assets/images/banana.png',
        category: 'Fruits',
      ),
    ];
  }
}

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _useFirestore = true; // Set to false for testing without Firebase

  List<Product> get products => [..._products];
  List<String> get categories => [..._categories];
  bool get isLoading => _isLoading;

  List<Product> get featuredProducts => 
      _products.where((product) => product.isFeatured).toList();

  ProductProvider() {
    fetchProducts();
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Get a single product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch products from Firestore
  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirestore) {
        // Fetch from Firestore
        QuerySnapshot snapshot = await _firestore.collection('products').get();
        
        _products = snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();
            
        // Extract unique categories
        Set<String> categoriesSet = {};
        for (var product in _products) {
          categoriesSet.add(product.category);
        }
        _categories = categoriesSet.toList();
      } else {
        // Use dummy data for development/testing
        _products = Product.getDummyProducts();
        _categories = _products
            .map((product) => product.category)
            .toSet()
            .toList();
      }
    } catch (e) {
      print("Error fetching products: $e");
      // Fallback to dummy data if Firestore fetch fails
      _products = Product.getDummyProducts();
      _categories = _products
          .map((product) => product.category)
          .toSet()
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products by name
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) => 
        product.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}