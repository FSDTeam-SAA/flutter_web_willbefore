// import 'package:flutter/material.dart';
// import '../data/dummy_data.dart';
// import '../theme/app_theme.dart';

// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({super.key});

//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen> {
//   final _categoryController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final categories = DummyData.categories;
    
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           // Header with Add Category Button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Product Categories',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () => _showAddCategoryDialog(context),
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add Category'),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 24),
          
//           // Categories Grid
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1.5,
//               ),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final category = categories[index];
                
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryLaurel.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           child: const Icon(
//                             Icons.category,
//                             color: AppColors.primaryLaurel,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           category,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: AppTheme.textPrimary,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               onPressed: () => _showEditCategoryDialog(context, category),
//                               icon: const Icon(
//                                 Icons.edit_outlined,
//                                 size: 18,
//                                 color: AppColors.primaryLaurel,
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () => _showDeleteCategoryDialog(context, category),
//                               icon: const Icon(
//                                 Icons.delete_outline,
//                                 size: 18,
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddCategoryDialog(BuildContext context) {
//     _categoryController.clear();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add Category'),
//           content: TextFormField(
//             controller: _categoryController,
//             decoration: const InputDecoration(
//               hintText: 'Enter category name...',
//             ),
//             autofocus: true,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_categoryController.text.isNotEmpty) {
//                   Navigator.of(context).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Category added successfully!'),
//                       backgroundColor: AppColors.primaryLaurel,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showEditCategoryDialog(BuildContext context, String category) {
//     _categoryController.text = category;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Edit Category'),
//           content: TextFormField(
//             controller: _categoryController,
//             decoration: const InputDecoration(
//               hintText: 'Enter category name...',
//             ),
//             autofocus: true,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_categoryController.text.isNotEmpty) {
//                   Navigator.of(context).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Category updated successfully!'),
//                       backgroundColor: AppColors.primaryLaurel,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Update'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDeleteCategoryDialog(BuildContext context, String category) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Category'),
//           content: Text('Are you sure you want to delete "$category"?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Category deleted successfully!'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('Delete', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _categoryController.dispose();
//     super.dispose();
//   }
// }