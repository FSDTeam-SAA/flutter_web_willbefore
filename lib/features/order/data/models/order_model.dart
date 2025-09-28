import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutx_core/flutx_core.dart'; // Added flutx_core import for DPrint logging
import '../../domain/entities/order_entities.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final ShippingAddressModel shippingAddress;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? paymentIntentId;
  final String? trackingNumber;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    this.paymentIntentId,
    this.trackingNumber,
    this.updatedAt,
  });

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      items: order.items,
      shippingAddress: ShippingAddressModel.fromEntity(order.shippingAddress),
      subtotal: order.subtotal,
      tax: order.tax,
      total: order.total,
      status: order.status.name,
      createdAt: order.createdAt,
      estimatedDelivery: order.estimatedDelivery,
      paymentIntentId: order.paymentIntentId,
      trackingNumber: order.trackingNumber,
      updatedAt: order.updatedAt,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DPrint.log(
      '🐞 DEBUG: Converting Firestore document to OrderModel: ${doc.data()}',
    );

    List<CartItem> items = [];
    try {
      final itemsData = data['items'] as List<dynamic>?;
      if (itemsData != null) {
        items = itemsData
            .map((item) {
              try {
                return CartItemModel.fromMap(item).toCartItem();
              } catch (e) {
                DPrint.log('🚨 Error converting cart item: $e');
                // Return a placeholder CartItem to prevent complete failure
                return CartItem(
                  id: 'error-${DateTime.now().millisecondsSinceEpoch}',
                  product: item['product'] ?? 'unknown',
                  quantity: item['quantity'] ?? 1,
                  selectedSize: item['selectedSize'],
                  selectedColor: item['selectedColor'],
                  // product: Product(
                  //   id: item['productId'] ?? 'unknown',
                  //   title: item['productName'] ?? 'Error Loading Product',
                  //   description: item['productDescription'] ?? '',
                  //   actualPrice:
                  //       (item['productActualPrice'] ??
                  //               item['productPrice'] ??
                  //               0.0)
                  //           .toDouble(),
                  //   discountPrice: item['productDiscountPrice'] != null
                  //       ? (item['productDiscountPrice'] as num).toDouble()
                  //       : null,
                  //   stock: item['productStock'] ?? 0,
                  //   categoryId: item['productCategoryId'] ?? '',
                  //   promoId: item['productPromoId'],
                  //   sizes: item['productSizes'] != null
                  //       ? List<String>.from(item['productSizes'])
                  //       : [],
                  //   colors: item['productColors'] != null
                  //       ? List<String>.from(item['productColors'])
                  //       : [],
                  //   colorCodes: item['productColorCodes'] != null
                  //       ? List<String>.from(item['productColorCodes'])
                  //       : [],
                  //   imageUrls: item['productImageUrls'] != null
                  //       ? List<String>.from(item['productImageUrls'])
                  //       : item['productImage'] != null
                  //       ? [item['productImage']]
                  //       : [],
                  //   facilities: item['productFacilities'] != null
                  //       ? Map<String, dynamic>.from(item['productFacilities'])
                  //       : null,
                  //   isActive: item['productIsActive'] ?? true,
                  //   createdAt: item['productCreatedAt'] is int
                  //       ? DateTime.fromMillisecondsSinceEpoch(
                  //           item['productCreatedAt'],
                  //         )
                  //       : (item['productCreatedAt'] is String
                  //             ? DateTime.tryParse(item['productCreatedAt']) ??
                  //                   DateTime.now()
                  //             : DateTime.now()),
                  //   updatedAt: item['productUpdatedAt'] is int
                  //       ? DateTime.fromMillisecondsSinceEpoch(
                  //           item['productUpdatedAt'],
                  //         )
                  //       : (item['productUpdatedAt'] is String
                  //             ? DateTime.tryParse(item['productUpdatedAt']) ??
                  //                   DateTime.now()
                  //             : DateTime.now()),
                  // ),
                );
              }
            })
            .cast<CartItem>()
            .toList();
      }
      DPrint.log('✅ Successfully converted ${items.length} items');
    } catch (e) {
      DPrint.log('🚨 Error processing items array: $e');
      items = [];
    }

    DateTime? parseTimestamp(dynamic timestamp) {
      try {
        if (timestamp is Timestamp) {
          return timestamp.toDate();
        }
        if (timestamp is int) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
        return null;
      } catch (e) {
        DPrint.log('🚨 Error parsing timestamp: $e');
        return null;
      }
    }

    ShippingAddressModel shippingAddress;
    try {
      final addressData = data['shippingAddress'];
      if (addressData is Map) {
        shippingAddress = ShippingAddressModel.fromMap(
          Map<String, dynamic>.from(addressData),
        );
      } else {
        DPrint.log('⚠️ Invalid shipping address data, using defaults');
        shippingAddress = ShippingAddressModel.fromMap({});
      }
    } catch (e) {
      DPrint.log('🚨 Error converting shipping address: $e');
      shippingAddress = ShippingAddressModel.fromMap({});
    }

    final orderModel = OrderModel(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      items: items,
      shippingAddress: shippingAddress,
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: data['status']?.toString() ?? 'pending',
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      estimatedDelivery: parseTimestamp(data['estimatedDelivery']),
      paymentIntentId: data['paymentIntentId']?.toString(),
      trackingNumber: data['trackingNumber']?.toString(),
      updatedAt: parseTimestamp(data['updatedAt']),
    );

    DPrint.log('✅ Successfully created OrderModel with ${items.length} items');
    return orderModel;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items
          .map((item) => CartItemModel.fromCartItem(item).toMap())
          .toList(),
      'shippingAddress': shippingAddress.toMap(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'estimatedDelivery': estimatedDelivery != null
          ? Timestamp.fromDate(estimatedDelivery!)
          : null,
      'paymentIntentId': paymentIntentId,
      'trackingNumber': trackingNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Order toEntity() {
    return Order(
      id: id,
      userId: userId,
      items: items,
      shippingAddress: shippingAddress.toEntity(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => OrderStatus.pending,
      ),
      createdAt: createdAt,
      estimatedDelivery: estimatedDelivery,
      paymentIntentId: paymentIntentId,
      trackingNumber: trackingNumber,
      updatedAt: updatedAt,
    );
  }
}

class ShippingAddressModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  const ShippingAddressModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddressModel.fromEntity(ShippingAddress address) {
    return ShippingAddressModel(
      firstName: address.fullName.split(' ').first,
      lastName: address.fullName.split(' ').last,
      email: address.email,
      phoneNumber: address.phoneNumber,
      address: address.addressLine1,
      city: address.city,
      state: address.state,
      zipCode: address.postalCode,
      country: address.country,
    );
  }

  factory ShippingAddressModel.fromMap(Map<String, dynamic> map) {
    return ShippingAddressModel(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  ShippingAddress toEntity() {
    return ShippingAddress(
      phoneNumber: phoneNumber,
      city: city,
      state: state,
      country: country,
      fullName: '$firstName $lastName',
      addressLine1: address,
      postalCode: zipCode,
      email: email, // Added email field to entity conversion
    );
  }
}
