// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../data/dummy_data.dart';
// import '../theme/app_theme.dart';

// class EditProductScreen extends StatefulWidget {
//   final String productId;

//   const EditProductScreen({
//     super.key,
//     required this.productId,
//   });

//   @override
//   State<EditProductScreen> createState() => _EditProductScreenState();
// }

// class _EditProductScreenState extends State<EditProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _actualPriceController = TextEditingController();
//   final _discountPriceController = TextEditingController();
//   final _stockController = TextEditingController();
//   final _descriptionController = TextEditingController();
  
//   String? _selectedCategory;
//   String? _selectedPromo;
//   final List<String> _selectedSizes = [];
//   final List<String> _selectedColors = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadProductData();
//   }

//   void _loadProductData() {
//     // Find product by ID and populate form
//     final product = DummyData.products.firstWhere(
//       (p) => p.id == widget.productId,
//       orElse: () => DummyData.products.first,
//     );

//     _titleController.text = product.title;
//     _actualPriceController.text = product.actualPrice.toString();
//     _discountPriceController.text = product.discountPrice.toString();
//     _stockController.text = product.stock.toString();
//     _descriptionController.text = product.description;
//     _selectedCategory = product.category;
//     _selectedSizes.addAll(product.sizes);
//     _selectedColors.addAll(product.colors);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Edit Product: ${_titleController.text}',
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 32),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Left Column
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildProductTitleSection(),
//                       const SizedBox(height: 24),
//                       _buildPricingSection(),
//                       const SizedBox(height: 24),
//                       _buildCategorySection(),
//                       const SizedBox(height: 24),
//                       _buildDescriptionSection(),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(width: 32),
                
//                 // Right Column
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSizeSection(),
//                       const SizedBox(height: 24),
//                       _buildColorSection(),
//                       const SizedBox(height: 32),
//                       _buildActionButtons(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductTitleSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Product Title',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _titleController,
//           decoration: const InputDecoration(
//             hintText: 'Enter product title...',
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter a product title';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPricingSection() {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Actual Price',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _actualPriceController,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter actual price...',
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter actual price';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Discount Price',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _discountPriceController,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter discount price...',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Stock',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _stockController,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter stock quantity...',
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter stock quantity';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategorySection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Category',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         DropdownButtonFormField<String>(
//           value: _selectedCategory,
//           decoration: const InputDecoration(
//             hintText: 'Select a category',
//           ),
//           items: DummyData.categories.map((category) {
//             return DropdownMenuItem(
//               value: category,
//               child: Text(category),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedCategory = value;
//             });
//           },
//           validator: (value) {
//             if (value == null) {
//               return 'Please select a category';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Description',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _descriptionController,
//           maxLines: 5,
//           decoration: const InputDecoration(
//             hintText: 'Enter product description...',
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter a product description';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildSizeSection() {
//     final availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Available Sizes',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: availableSizes.map((size) {
//             final isSelected = _selectedSizes.contains(size);
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (isSelected) {
//                     _selectedSizes.remove(size);
//                   } else {
//                     _selectedSizes.add(size);
//                   }
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.primaryLaurel : Colors.grey[200],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   size,
//                   style: TextStyle(
//                     color: isSelected ? Colors.white : AppTheme.textPrimary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildColorSection() {
//     final availableColors = ['Red', 'Black', 'White', 'Blue', 'Green'];
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Available Colors',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: availableColors.map((color) {
//             final isSelected = _selectedColors.contains(color);
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (isSelected) {
//                     _selectedColors.remove(color);
//                   } else {
//                     _selectedColors.add(color);
//                   }
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.primaryLaurel : Colors.grey[200],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   color,
//                   style: TextStyle(
//                     color: isSelected ? Colors.white : AppTheme.textPrimary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => context.go('/products'),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               side: const BorderSide(color: AppTheme.borderColor),
//             ),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: AppTheme.textSecondary),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 // Update product logic here
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Product updated successfully!'),
//                     backgroundColor: AppColors.primaryLaurel,
//                   ),
//                 );
//                 context.go('/products');
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: const Text('Update Product'),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _actualPriceController.dispose();
//     _discountPriceController.dispose();
//     _stockController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }