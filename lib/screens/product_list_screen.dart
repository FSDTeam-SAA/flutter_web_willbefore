import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final products = DummyData.products;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header with Add Product Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/products/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Products Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderColor),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 60, child: Text('Image', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Category', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Stock', style: TextStyle(fontWeight: FontWeight.w600))),
                        SizedBox(width: 100, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  
                  // Table Body
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: index == products.length - 1 
                                  ? Colors.transparent 
                                  : AppTheme.borderColor,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Product Image
                              SizedBox(
                                width: 60,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.cake,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                              
                              // Product Name
                              Expanded(
                                flex: 2,
                                child: Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              
                              // Category
                              Expanded(
                                child: Text(
                                  product.category,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              
                              // Price
                              Expanded(
                                child: Text(
                                  '\$${product.actualPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              
                              // Stock
                              Expanded(
                                child: Text(
                                  '${product.stock} in stock',
                                  style: TextStyle(
                                    color: product.stock > 20 
                                      ? Colors.green 
                                      : product.stock > 5 
                                        ? Colors.orange 
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Actions
                              SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => context.go('/products/edit/${product.id}'),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteDialog(context, product.id);
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  void _showDeleteDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}