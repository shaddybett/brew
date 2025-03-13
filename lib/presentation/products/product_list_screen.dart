import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_delivery_app/providers/product_provider.dart';
import 'package:grocery_delivery_app/providers/cart_provider.dart';
import 'package:grocery_delivery_app/router/app_router.dart';
import 'package:grocery_delivery_app/utils/constants/colors.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.category});
  
  final String? category;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedCategory = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If category was passed to the screen, set it as selected
    if (widget.category != null && widget.category!.isNotEmpty) {
      _selectedCategory = widget.category!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final categories = productProvider.categories;
    
    // Filter products based on selected category and search query
    List<Product> filteredProducts = productProvider.products;
    
    if (_selectedCategory.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => 
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategory.isEmpty 
            ? "All Products" 
            : _selectedCategory),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.cart);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Categories filter
          if (categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1, // +1 for "All" option
                itemBuilder: (context, index) {
                  // First item is "All"
                  if (index == 0) {
                    return _buildCategoryChip('All', _selectedCategory.isEmpty);
                  }
                  
                  final category = categories[index - 1];
                  return _buildCategoryChip(
                      category, _selectedCategory == category);
                },
              ),
            ),
          
          // Product grid
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? const Center(child: Text('No products found'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product, cartProvider);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (category == 'All') {
            _selectedCategory = '';
          } else {
            _selectedCategory = category;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, CartProvider cartProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              width: double.infinity,
              child: product.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      product.imageUrl,
                      fit: BoxFit.contain,
                    )
                  : Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: primaryColor,
                      ),
                    ),
            ),
          ),
          
          // Product details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cartProvider.addItem(
                          product.id,
                          product.name,
                          product.price,
                          product.imageUrl,
                        );
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                cartProvider.removeSingleItem(product.id);
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(double.infinity, 30),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}