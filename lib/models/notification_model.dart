import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  new_product,
  orderShipped,
  orderRefunded,
  general,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;
  final NotificationType type;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
    required this.type,
    this.imageUrl,
    this.metadata,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
      type: _parseType(data['type']),
      imageUrl: data['imageUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'read': read,
      'type': type.name,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'new_product':
        return NotificationType.new_product;
      case 'orderShipped':
        return NotificationType.orderShipped;
      case 'orderRefunded':
        return NotificationType.orderRefunded;
      default:
        return NotificationType.general;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? read,
    NotificationType? type,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
