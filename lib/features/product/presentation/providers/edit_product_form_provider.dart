import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entrity/product.dart';
import 'add_product_form.dart';

// Edit Product Form Data
class EditProductFormData {
  final String id;
  final String title;
  final String description;
  final String actualPrice;
  final String discountPrice;
  final String stock;
  final String? selectedCategoryId;
  final String? selectedPromoId;
  final List<ProductImage> selectedImages;
  final List<String> selectedSizes;
  final List<ProductColor> selectedColors;
  final String overOrderDiscount;
  final String freeReturnDays;
  final String customSize;
  final String customColorName;
  final List<String> existingImageUrls;

  const EditProductFormData({
    required this.id,
    this.title = '',
    this.description = '',
    this.actualPrice = '',
    this.discountPrice = '',
    this.stock = '',
    this.selectedCategoryId,
    this.selectedPromoId,
    this.selectedImages = const [],
    this.selectedSizes = const [],
    this.selectedColors = const [],
    this.overOrderDiscount = '',
    this.freeReturnDays = '',
    this.customSize = '',
    this.customColorName = '',
    this.existingImageUrls = const [],
  });

  EditProductFormData copyWith({
    String? id,
    String? title,
    String? description,
    String? actualPrice,
    String? discountPrice,
    String? stock,
    String? selectedCategoryId,
    String? selectedPromoId,
    List<ProductImage>? selectedImages,
    List<String>? selectedSizes,
    List<ProductColor>? selectedColors,
    String? overOrderDiscount,
    String? freeReturnDays,
    String? customSize,
    String? customColorName,
    List<String>? existingImageUrls,
  }) {
    return EditProductFormData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      actualPrice: actualPrice ?? this.actualPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedPromoId: selectedPromoId ?? this.selectedPromoId,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      selectedColors: selectedColors ?? this.selectedColors,
      overOrderDiscount: overOrderDiscount ?? this.overOrderDiscount,
      freeReturnDays: freeReturnDays ?? this.freeReturnDays,
      customSize: customSize ?? this.customSize,
      customColorName: customColorName ?? this.customColorName,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
    );
  }
}

// Edit Product Form State Notifier
class EditProductFormNotifier extends StateNotifier<EditProductFormData> {
  EditProductFormNotifier(String productId) : super(EditProductFormData(id: productId));

  // Default sizes and colors (same as add form)
  static const List<String> defaultSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '2XL', '3XL'];
  static const List<ProductColor> defaultColors = [
    ProductColor(name: 'Red', color: Colors.red),
    ProductColor(name: 'Black', color: Colors.black),
    ProductColor(name: 'White', color: Colors.white),
    ProductColor(name: 'Blue', color: Colors.blue),
    ProductColor(name: 'Green', color: Colors.green),
    ProductColor(name: 'Yellow', color: Colors.yellow),
    ProductColor(name: 'Purple', color: Colors.purple),
    ProductColor(name: 'Orange', color: Colors.orange),
    ProductColor(name: 'Pink', color: Colors.pink),
    ProductColor(name: 'Grey', color: Colors.grey),
  ];

  static const int maxImages = 6;

  void initializeFromProduct(Product product) {
    // Convert product colors to ProductColor objects
    final productColors = <ProductColor>[];
    for (int i = 0; i < product.colors.length; i++) {
      final colorName = product.colors[i];
      Color color = Colors.grey; // Default color
      
      if (i < product.colorCodes.length) {
        try {
          final colorCode = product.colorCodes[i];
          color = Color(int.parse(colorCode, radix: 16));
        } catch (e) {
          // Use default color if parsing fails
        }
      }
      
      productColors.add(ProductColor(name: colorName, color: color));
    }

    state = EditProductFormData(
      id: product.id,
      title: product.title,
      description: product.description,
      actualPrice: product.actualPrice.toString(),
      discountPrice: product.discountPrice?.toString() ?? '',
      stock: product.stock.toString(),
      selectedCategoryId: product.categoryId,
      selectedPromoId: product.promoId,
      selectedSizes: List.from(product.sizes),
      selectedColors: productColors,
      overOrderDiscount: product.facilities?['overOrderDiscount']?.toString() ?? '',
      freeReturnDays: product.facilities?['freeReturnDays']?.toString() ?? '',
      existingImageUrls: List.from(product.imageUrls),
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateActualPrice(String price) {
    state = state.copyWith(actualPrice: price);
  }

  void updateDiscountPrice(String price) {
    state = state.copyWith(discountPrice: price);
  }

  void updateStock(String stock) {
    state = state.copyWith(stock: stock);
  }

  void updateSelectedCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void updateSelectedPromo(String? promoId) {
    state = state.copyWith(selectedPromoId: promoId);
  }

  void updateOverOrderDiscount(String discount) {
    state = state.copyWith(overOrderDiscount: discount);
  }

  void updateFreeReturnDays(String days) {
    state = state.copyWith(freeReturnDays: days);
  }

  void updateCustomSize(String size) {
    state = state.copyWith(customSize: size);
  }

  void updateCustomColorName(String colorName) {
    state = state.copyWith(customColorName: colorName);
  }

  void addImages(List<ProductImage> newImages) {
    final currentImages = List<ProductImage>.from(state.selectedImages);
    final totalImages = currentImages.length + state.existingImageUrls.length;
    
    for (var image in newImages) {
      if (totalImages + currentImages.length - state.selectedImages.length < maxImages) {
        currentImages.add(image);
      }
    }
    state = state.copyWith(selectedImages: currentImages);
  }

  void removeImage(int index) {
    final images = List<ProductImage>.from(state.selectedImages);
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      state = state.copyWith(selectedImages: images);
    }
  }

  void removeExistingImage(int index) {
    final existingUrls = List<String>.from(state.existingImageUrls);
    if (index >= 0 && index < existingUrls.length) {
      existingUrls.removeAt(index);
      state = state.copyWith(existingImageUrls: existingUrls);
    }
  }

  void addCustomSize() {
    if (state.customSize.isNotEmpty) {
      final size = state.customSize.trim().toUpperCase();
      final sizes = List<String>.from(state.selectedSizes);
      if (!sizes.contains(size)) {
        sizes.add(size);
        state = state.copyWith(
          selectedSizes: sizes,
          customSize: '',
        );
      }
    }
  }

  void toggleDefaultSize(String size) {
    final sizes = List<String>.from(state.selectedSizes);
    if (sizes.contains(size)) {
      sizes.remove(size);
    } else {
      sizes.add(size);
    }
    state = state.copyWith(selectedSizes: sizes);
  }

  void removeSize(String size) {
    final sizes = List<String>.from(state.selectedSizes);
    sizes.remove(size);
    state = state.copyWith(selectedSizes: sizes);
  }

  void toggleDefaultColor(ProductColor color) {
    final colors = List<ProductColor>.from(state.selectedColors);
    final existingIndex = colors.indexWhere((c) => c.name == color.name);
    if (existingIndex != -1) {
      colors.removeAt(existingIndex);
    } else {
      colors.add(color);
    }
    state = state.copyWith(selectedColors: colors);
  }

  void addCustomColor(String colorName, Color color) {
    final colors = List<ProductColor>.from(state.selectedColors);
    final existingIndex = colors.indexWhere((c) => c.name.toLowerCase() == colorName.toLowerCase());
    
    final newColor = ProductColor(name: colorName, color: color);
    if (existingIndex != -1) {
      colors[existingIndex] = newColor;
    } else {
      colors.add(newColor);
    }
    
    state = state.copyWith(
      selectedColors: colors,
      customColorName: '',
    );
  }

  void removeColor(int index) {
    final colors = List<ProductColor>.from(state.selectedColors);
    if (index >= 0 && index < colors.length) {
      colors.removeAt(index);
      state = state.copyWith(selectedColors: colors);
    }
  }

  void reset(String productId) {
    state = EditProductFormData(id: productId);
  }
}

// Provider factory for edit product form
final editProductFormProvider = StateNotifierProvider.family<EditProductFormNotifier, EditProductFormData, String>((ref, productId) {
  return EditProductFormNotifier(productId);
});
