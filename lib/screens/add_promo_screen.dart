// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../theme/app_theme.dart';

// class AddPromoScreen extends StatefulWidget {
//   const AddPromoScreen({super.key});

//   @override
//   State<AddPromoScreen> createState() => _AddPromoScreenState();
// }

// class _AddPromoScreenState extends State<AddPromoScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _codeController = TextEditingController();
//   final _startDateController = TextEditingController();
//   final _endDateController = TextEditingController();
  
//   DateTime? _startDate;
//   DateTime? _endDate;

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
    
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//           _startDateController.text = '${picked.day}/${picked.month}/${picked.year}';
//         } else {
//           _endDate = picked;
//           _endDateController.text = '${picked.day}/${picked.month}/${picked.year}';
//         }
//       });
//     }
//   }

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
//                   _buildPromoTitleSection(),
//                   const SizedBox(height: 24),
//                   _buildPromoCodeSection(),
//                   const SizedBox(height: 24),
//                   _buildDateSection(),
//                   const SizedBox(height: 32),
//                   _buildActionButtons(),
//                 ],
//               ),
//             ),
            
//             const SizedBox(width: 32),
            
//             // Right Column
//             Expanded(
//               child: _buildImageSection(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPromoTitleSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Add promo title',
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
//             hintText: 'Enter promo title...',
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter a promo title';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPromoCodeSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Add Code',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _codeController,
//           decoration: const InputDecoration(
//             hintText: 'Enter promo code...',
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter a promo code';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDateSection() {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Start Date',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _startDateController,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   hintText: 'Enter start date...',
//                   suffixIcon: IconButton(
//                     onPressed: () => _selectDate(context, true),
//                     icon: const Icon(Icons.calendar_today),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select start date';
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
//                 'End Date',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _endDateController,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   hintText: 'Enter end date...',
//                   suffixIcon: IconButton(
//                     onPressed: () => _selectDate(context, false),
//                     icon: const Icon(Icons.calendar_today),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select end date';
//                   }
//                   if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
//                     return 'End date must be after start date';
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

//   Widget _buildImageSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Add Promo Image',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           height: 300,
//           width: double.infinity,
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
//                   size: 64,
//                   color: AppTheme.textSecondary,
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'Click to upload promo image',
//                   style: TextStyle(
//                     color: AppTheme.textSecondary,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => context.go('/promos'),
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
//                 // Save promo logic here
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Promo saved successfully!'),
//                     backgroundColor: AppColors.primaryLaurel,
//                   ),
//                 );
//                 context.go('/promos');
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
//     _codeController.dispose();
//     _startDateController.dispose();
//     _endDateController.dispose();
//     super.dispose();
//   }
// }