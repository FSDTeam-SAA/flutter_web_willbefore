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
      // Sources for product data (priority to nested 'product' or 'data')
      final nestedProduct = (map['product'] is Map
          ? map['product'] as Map<String, dynamic>
          : (map['data'] is Map ? map['data'] as Map<String, dynamic> : null));

      final sources = [if (nestedProduct != null) nestedProduct, map];

      // Helper to get value from multiple possible keys across multiple sources
      dynamic getFromSources(List<String> keys) {
        for (var source in sources) {
          for (var key in keys) {
            if (source.containsKey(key) && source[key] != null)
              return source[key];
          }
        }
        return null;
      }

      return CartItemModel(
        id:
            map['id']?.toString() ??
            map['item_id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        productId:
            getFromSources(['productId', 'product_id', 'id'])?.toString() ?? '',
        productName:
            getFromSources([
              'productName',
              'product_name',
              'name',
              'title',
            ])?.toString() ??
            'Unknown Product',
        productPrice:
            (getFromSources([
                      'productPrice',
                      'product_price',
                      'price',
                      'actualPrice',
                    ]) ??
                    0.0)
                .toDouble(),
        productImage: (() {
          final img = getFromSources([
            'productImage',
            'product_image',
            'image',
            'imageUrl',
            'image_url',
            'imageUrls',
          ]);
          if (img is List && img.isNotEmpty) return img.first.toString();
          return img?.toString();
        })(),
        quantity: (map['quantity'] ?? map['qty'] ?? 1).toInt(),
        selectedSize: (map['selectedSize'] ?? map['size'])?.toString(),
        selectedColor: (map['selectedColor'] ?? map['color'])?.toString(),
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
