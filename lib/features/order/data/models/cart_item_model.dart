import 'package:flutx_core/flutx_core.dart';

import '../../../product/domain/entrity/product.dart';
import '../../domain/entities/order_entities.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final double productPrice;
  final String? productImage;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.productImage,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });

  factory CartItemModel.fromCartItem(CartItem cartItem) {
    return CartItemModel(
      id: cartItem.id,
      productId: cartItem.product.id,
      productName: cartItem.product.title,
      productPrice: cartItem.product.effectivePrice,
      productImage: cartItem.product.imageUrls.isNotEmpty
          ? cartItem.product.imageUrls.first
          : null,
      quantity: cartItem.quantity,
      selectedSize: cartItem.selectedSize,
      selectedColor: cartItem.selectedColor,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    try {
      return CartItemModel(
        id:
            map['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        productId: map['productId']?.toString() ?? '',
        productName: map['productName']?.toString() ?? 'Unknown Product',
        productPrice: (map['productPrice'] ?? 0.0).toDouble(),
        productImage: map['productImage']?.toString(),
        quantity: (map['quantity'] ?? 1).toInt(),
        selectedSize: map['selectedSize']?.toString(),
        selectedColor: map['selectedColor']?.toString(),
      );
    } catch (e) {
      DPrint.log('🚨 Error in CartItemModel.fromMap: $e, data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  CartItem toCartItem() {
    return CartItem(
      id: id,
      // productId: productId,
      // productName: productName,
      // productPrice: productPrice,
      // productImage: productImage,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      product: Product(
        id: productId,
        title: productName,
        actualPrice: productPrice,
        discountPrice: null, // Assuming no discount for now
        stock: 0, // Stock not used in CartItem
        categoryId: '', // Category not used in CartItem
        promoId: null, // Promo not used in CartItem
        sizes: [],
        colors: [],
        colorCodes: [],
        imageUrls: [productImage ?? ''],
        facilities: {},
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
      ),
    );
  }
}
