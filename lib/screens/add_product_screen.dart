// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../data/dummy_data.dart';
// import '../theme/app_theme.dart';

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _actualPriceController = TextEditingController();
//   final _discountPriceController = TextEditingController();
//   final _stockController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _colorCodeController = TextEditingController();
//   final _sizeController = TextEditingController();
  
//   String? _selectedCategory;
//   String? _selectedPromo;
//   final List<String> _selectedSizes = [];
//   final List<String> _selectedColors = [];
//   final List<String> _availableColors = ['Red', 'Black', 'White', 'Blue', 'Green'];
//   final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: _formKey,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Left Column
//             Expanded(
//               flex: 2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProductTitleSection(),
//                   const SizedBox(height: 24),
//                   _buildPricingSection(),
//                   const SizedBox(height: 24),
//                   _buildCategoryPromoSection(),
//                   const SizedBox(height: 24),
//                   _buildDescriptionSection(),
//                   const SizedBox(height: 24),
//                   _buildFacilitiesSection(),
//                 ],
//               ),
//             ),
            
//             const SizedBox(width: 32),
            
//             // Right Column
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildImageSection(),
//                   const SizedBox(height: 24),
//                   _buildSizeSection(),
//                   const SizedBox(height: 24),
//                   _buildColorSection(),
//                   const SizedBox(height: 32),
//                   _buildActionButtons(),
//                 ],
//               ),
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
//           'Add product title',
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
//             hintText: 'Add your title...',
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
//                 'Actual_Price',
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
//                   hintText: 'Add product price...',
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
//                 'Discount_Price',
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
//                   hintText: 'Add product discount price...',
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
//                 'Stocks',
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
//                   hintText: 'Add product stock...',
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

//   Widget _buildCategoryPromoSection() {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Select Product Categories',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: _selectedCategory,
//                 decoration: const InputDecoration(
//                   hintText: 'Select a categories',
//                 ),
//                 items: DummyData.categories.map((category) {
//                   return DropdownMenuItem(
//                     value: category,
//                     child: Text(category),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCategory = value;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null) {
//                     return 'Please select a category';
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
//                 'Select product Promo',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: _selectedPromo,
//                 decoration: const InputDecoration(
//                   hintText: 'Select a promo',
//                 ),
//                 items: DummyData.promos.map((promo) {
//                   return DropdownMenuItem(
//                     value: promo.id,
//                     child: Text(promo.title),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedPromo = value;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Create Description',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: AppTheme.borderColor),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               // Toolbar
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: AppTheme.borderColor),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Text('Font'),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: AppTheme.borderColor),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: const Text('Body'),
//                     ),
//                     const SizedBox(width: 16),
//                     _buildToolbarButton(Icons.format_bold, 'B'),
//                     _buildToolbarButton(Icons.format_italic, 'I'),
//                     _buildToolbarButton(Icons.format_underlined, 'U'),
//                     const SizedBox(width: 16),
//                     const Text('Alignment'),
//                     const SizedBox(width: 8),
//                     _buildToolbarButton(Icons.format_align_left, ''),
//                     _buildToolbarButton(Icons.format_align_center, ''),
//                     _buildToolbarButton(Icons.format_align_right, ''),
//                     _buildToolbarButton(Icons.format_align_justify, ''),
//                     _buildToolbarButton(Icons.format_list_bulleted, ''),
//                   ],
//                 ),
//               ),
//               // Text Area
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 8,
//                 decoration: const InputDecoration(
//                   hintText: 'Type product description here...',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(16),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a product description';
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

//   Widget _buildToolbarButton(IconData icon, String text) {
//     return Container(
//       margin: const EdgeInsets.only(right: 4),
//       child: InkWell(
//         onTap: () {},
//         child: Container(
//           padding: const EdgeInsets.all(4),
//           child: text.isNotEmpty 
//             ? Text(text, style: const TextStyle(fontWeight: FontWeight.bold))
//             : Icon(icon, size: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildFacilitiesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Our Facilities',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppTheme.borderColor),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.local_offer, color: AppTheme.textSecondary),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text('Add over order discount price...'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   const Icon(Icons.refresh, color: AppTheme.textSecondary),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text('Add free return days...'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Add Product Image',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.add_photo_alternate_outlined,
//                   size: 48,
//                   color: AppTheme.textSecondary,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Click to upload image',
//                   style: TextStyle(color: AppTheme.textSecondary),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Thumbnail grid
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 5,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//           ),
//           itemCount: 5,
//           itemBuilder: (context, index) {
//             return Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.add_photo_alternate_outlined,
//                 color: AppTheme.textSecondary,
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildSizeSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Create Product Size',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textPrimary,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_sizeController.text.isNotEmpty) {
//                   setState(() {
//                     _selectedSizes.add(_sizeController.text);
//                     _sizeController.clear();
//                   });
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryLaurel,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//               child: const Text('Set', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _sizeController,
//           decoration: const InputDecoration(
//             hintText: 'Enter product size...',
//           ),
//         ),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: _availableSizes.map((size) {
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
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       size,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : AppTheme.textPrimary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     if (isSelected) ...[
//                       const SizedBox(width: 4),
//                       const Icon(
//                         Icons.close,
//                         size: 16,
//                         color: Colors.white,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildColorSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Write product Color Code',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textPrimary,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_colorCodeController.text.isNotEmpty) {
//                   setState(() {
//                     _selectedColors.add(_colorCodeController.text);
//                     _colorCodeController.clear();
//                   });
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryLaurel,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//               child: const Text('Set', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _colorCodeController,
//           decoration: const InputDecoration(
//             hintText: 'Enter a color code...',
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: _availableColors.map((color) {
//             final isSelected = _selectedColors.contains(color);
//             Color colorValue = Colors.grey;
//             switch (color) {
//               case 'Red':
//                 colorValue = Colors.red;
//                 break;
//               case 'Black':
//                 colorValue = Colors.black;
//                 break;
//               case 'White':
//                 colorValue = Colors.white;
//                 break;
//               case 'Blue':
//                 colorValue = Colors.blue;
//                 break;
//               case 'Green':
//                 colorValue = Colors.green;
//                 break;
//             }
            
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
//                 margin: const EdgeInsets.only(right: 8),
//                 child: Stack(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: colorValue,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: color == 'White' ? AppTheme.borderColor : Colors.transparent,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     if (isSelected)
//                       Positioned(
//                         top: -4,
//                         right: -4,
//                         child: Container(
//                           width: 16,
//                           height: 16,
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.close,
//                             size: 12,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                   ],
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
//                 // Save product logic here
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Product saved successfully!'),
//                     backgroundColor: AppColors.primaryLaurel,
//                   ),
//                 );
//                 context.go('/products');
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: const Text('Save'),
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
//     _colorCodeController.dispose();
//     _sizeController.dispose();
//     super.dispose();
//   }
// }