class PromoModel {
  final String id;
  final String title;
  final String code;
  final String description;
  final double discountPercentage;
  final double? discountAmount;
  final double? minimumOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final bool isActive;
  final int usageLimit;
  final int usedCount;
  final List<String> applicableProductIds;
  final List<String> applicableCategoryIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromoModel({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.discountPercentage,
    this.discountAmount,
    this.minimumOrderAmount,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.isActive = true,
    this.usageLimit = 0, // 0 means unlimited
    this.usedCount = 0,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromoModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PromoModel(
      id: id,
      title: data['title'] ?? '',
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      discountAmount: data['discountAmount']?.toDouble(),
      minimumOrderAmount: data['minimumOrderAmount']?.toDouble(),
      startDate: DateTime.fromMillisecondsSinceEpoch(data['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(data['endDate'] ?? 0),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      usageLimit: data['usageLimit'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      applicableProductIds: List<String>.from(data['applicableProductIds'] ?? []),
      applicableCategoryIds: List<String>.from(data['applicableCategoryIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'code': code,
      'description': description,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'minimumOrderAmount': minimumOrderAmount,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'applicableProductIds': applicableProductIds,
      'applicableCategoryIds': applicableCategoryIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate) &&
           (usageLimit == 0 || usedCount < usageLimit);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  PromoModel copyWith({
    String? id,
    String? title,
    String? code,
    String? description,
    double? discountPercentage,
    double? discountAmount,
    double? minimumOrderAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    bool? isActive,
    int? usageLimit,
    int? usedCount,
    List<String>? applicableProductIds,
    List<String>? applicableCategoryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableCategoryIds: applicableCategoryIds ?? this.applicableCategoryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}