import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isFeatured;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isFeatured = false,
    this.isAvailable = true,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? 'assets/images/placeholder.png',
      isFeatured: data['isFeatured'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
    };
  }
}

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;

  List<Product> get products {
    return [..._products];
  }

  List<String> get categories {
    return [..._categories];
  }

  bool get isLoading {
    return _isLoading;
  }

  List<Product> get featuredProducts {
    return _products.where((product) => product.isFeatured).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> findByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final productsSnapshot = await _firestore.collection('products').get();
      final List<Product> loadedProducts = [];
      final Set<String> loadedCategories = {};

      for (var doc in productsSnapshot.docs) {
        final product = Product.fromMap(doc.data(), doc.id);
        loadedProducts.add(product);
        loadedCategories.add(product.category);
      }

      _products = loadedProducts;
      _categories = loadedCategories.toList()..sort();
    } catch (error) {
      print('Error fetching products: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method for adding test products if you don't have Firebase data yet
  void addDummyProducts() {
    _products = [
      Product(
        id: 'p1',
        name: 'Apples',
        description: 'Fresh red apples',
        price: 2.99,
        category: 'Fruits',
        imageUrl: 'assets/images/apple.png',
        isFeatured: true,
      ),
      Product(
        id: 'p2',
        name: 'Bananas',
        description: 'Ripe yellow bananas',
        price: 1.99,
        category: 'Fruits',
        imageUrl: 'assets/images/banana.png',
      ),
      Product(
        id: 'p3',
        name: 'Milk',
        description: 'Fresh whole milk',
        price: 3.49,
        category: 'Dairy',
        imageUrl: 'assets/images/milk.png',
        isFeatured: true,
      ),
      Product(
        id: 'p4',
        name: 'Bread',
        description: 'Freshly baked bread',
        price: 2.49,
        category: 'Bakery',
        imageUrl: 'assets/images/bread.png',
      ),
      Product(
        id: 'p5',
        name: 'Chicken',
        description: 'Fresh chicken breast',
        price: 5.99,
        category: 'Meat',
        imageUrl: 'assets/images/chicken.png',
        isFeatured: true,
      ),
      Product(
        id: 'p6',
        name: 'Rice',
        description: 'Premium white rice',
        price: 3.99,
        category: 'Grains',
        imageUrl: 'assets/images/rice.png',
      ),
    ];

    _categories = ['Fruits', 'Dairy', 'Bakery', 'Meat', 'Grains'];
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toMap());
      final newProduct = Product(
        id: docRef.id,
        name: product.name,
        description: product.description,
        price: product.price,
        category: product.category,
        imageUrl: product.imageUrl,
        isFeatured: product.isFeatured,
        isAvailable: product.isAvailable,
      );
      
      _products.add(newProduct);
      if (!_categories.contains(product.category)) {
        _categories.add(product.category);
        _categories.sort();
      }
      notifyListeners();
    } catch (error) {
      print('Error adding product: $error');
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating product: $error');
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (error) {
      print('Error deleting product: $error');
      throw error;
    }
  }
}