import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            userName = "${userDoc['firstname']} ${userDoc['lastname']}";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery Delivery"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${userName ?? 'User'}!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Categories section
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoriesSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Featured products section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Featured Products",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.products);
                        },
                        child: const Text("See all"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturedProducts(),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Fruits', 'icon': Icons.apple},
      {'name': 'Vegetables', 'icon': Icons.eco},
      {'name': 'Dairy', 'icon': Icons.egg},
      {'name': 'Bakery', 'icon': Icons.bakery_dining},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categories[index]['icon'] as IconData,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    // Dummy product data - in a real app, this would come from your ProductProvider
    final products = [
      {
        'name': 'Fresh Apples',
        'price': 2.99,
        'image': Icons.apple,
        'description': 'Fresh red apples from local farms'
      },
      {
        'name': 'Organic Milk',
        'price': 3.49,
        'image': Icons.egg,
        'description': 'Organic full-cream milk'
      },
      {
        'name': 'Whole Wheat Bread',
        'price': 4.99,
        'image': Icons.bakery_dining,
        'description': 'Freshly baked whole wheat bread'
      },
    ];

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      products[index]['image'] as IconData,
                      size: 60,
                      color: primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        products[index]['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${products[index]['price']}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // In a real app, you'd add the product to cart here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${products[index]['name']} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}