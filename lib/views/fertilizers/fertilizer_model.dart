import 'dart:convert';

class Fertilizer {
  final String id;
  final String productName;
  final String mrpPrice;
  final String sellPrice;
  final String productQuantity; // e.g., "1", "500"
  final String productUnit; // e.g., "Ltr", "Gm"
  final String productId;
  final String soldQuantity;
  final int availableQuantity;
  final String status;
  final List<FertilizerImage> images;
  final bool isDeleted;
  final String createdAt;
  final String createdBy;
  final List<ActivityLog>? activityLog;
  final String category;
  final String? description;
  final ProductDetails? productDetails;
  final List<Review>? reviews;

  // COMPUTED VALUES (SUPER USEFUL)
  String get unit => '$productQuantity ${_formatUnit(productUnit)}';
  double get mrp => double.tryParse(mrpPrice) ?? 0.0;
  double get sell => double.tryParse(sellPrice) ?? 0.0;
  double get discountPercent => mrp > 0 ? ((mrp - sell) / mrp) * 100 : 0.0;
  String get specialDiscount =>
      discountPercent > 0 ? '${discountPercent.toStringAsFixed(0)}%' : '0%';
  double get discountedPrice => sell;
  int get availableStock => availableQuantity;

  Fertilizer({
    required this.id,
    required this.productName,
    required this.mrpPrice,
    required this.sellPrice,
    required this.productQuantity,
    required this.productUnit,
    required this.productId,
    required this.soldQuantity,
    required this.availableQuantity,
    required this.status,
    required this.images,
    required this.isDeleted,
    required this.createdAt,
    required this.createdBy,
    this.activityLog,
    required this.category,
    this.description,
    this.productDetails,
    this.reviews,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    // Parse images
    final List<FertilizerImage> images = [];
    final imgData = json['images'];

    if (imgData is List) {
      for (final img in imgData) {
        if (img is Map<String, dynamic>) {
          images.add(FertilizerImage.fromJson(img));
        } else if (img is String) {
          images.add(FertilizerImage(url: img));
        }
      }
    }

    // Parse activity log
    final List<ActivityLog> logs = [];
    final logData = json['activity_log'];
    if (logData is List) {
      logs.addAll(
          logData.map((l) => ActivityLog.fromJson(l as Map<String, dynamic>)));
    }

    // Parse reviews
    final List<Review> reviews = [];
    final reviewData = json['reviews'];
    if (reviewData is List) {
      reviews.addAll(
          reviewData.map((r) => Review.fromJson(r as Map<String, dynamic>)));
    }

    final int totalQty = _parseIntSafe(json['total_quantity']);
    final int soldQty = _parseIntSafe(json['sold_quantity']);

    return Fertilizer(
      id: json['_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Unknown Product',
      mrpPrice: json['mrp_price']?.toString() ?? '0',
      sellPrice: json['sell_price']?.toString() ?? '0',
      productQuantity: json['product_quantity']?.toString() ?? '1',
      productUnit: json['product_unit']?.toString() ?? 'Unit',
      productId: json['product_id']?.toString() ?? '',
      soldQuantity: soldQty.toString(),

      //stock logic: available = total - sold
      availableQuantity: (totalQty - soldQty).clamp(0, totalQty),

      status: json['product_status']?.toString() ?? 'Unknown',
      images: images,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: (json['created_at'] as String?) ?? '',
      createdBy: (json['created_by'] as String?) ?? '',
      activityLog: logs.isNotEmpty ? logs : null,
      category: json['product_category']?.toString() ?? 'Unknown',
      description: json['product_descriptions'] as String?,
      productDetails: json['product_details'] != null
          ? ProductDetails.fromJson(
              json['product_details'] as Map<String, dynamic>)
          : null,
      reviews: reviews.isNotEmpty ? reviews : null,
    );
  }

  static String _formatUnit(String unit) {
    final map = {
      'Ltr': 'Ltr',
      'ltr': 'Ltr',
      'Gm': 'Gm',
      'gm': 'Gm',
      'Kg': 'Kg',
      'kg': 'Kg',
      'Ml': 'ml',
      'ml': 'ml',
    };
    return map[unit.trim()] ?? unit.trim();
  }

  static int _parseIntSafe(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

// Supporting Classes (unchanged)
class FertilizerImage {
  final String fileName;
  final String url;

  FertilizerImage({this.fileName = '', required this.url});

  factory FertilizerImage.fromJson(Map<String, dynamic> json) {
    return FertilizerImage(
      fileName: json['fileName'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class ActivityLog {
  final String action;
  final String actionAt;

  ActivityLog({required this.action, required this.actionAt});

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      action: json['action'] as String? ?? '',
      actionAt: json['action_at'] as String? ?? '',
    );
  }
}

class ProductDetails {
  final String content;
  final String expiryDate;
  final String usage;

  ProductDetails({
    required this.content,
    required this.expiryDate,
    required this.usage,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      content: json['content'] as String? ?? '',
      expiryDate: json['expiry_date'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
    );
  }
}

class Review {
  final String farmer;
  final String comment;
  final String rating;
  final String actionAt;

  Review({
    required this.farmer,
    required this.comment,
    required this.rating,
    required this.actionAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      farmer: json['farmer'] as String? ?? 'Anonymous',
      comment: json['comment'] as String? ?? '',
      rating: json['rating'] as String? ?? '0',
      actionAt: json['action_at'] as String? ?? '',
    );
  }
}

// NEW: Fully Updated Rich Order Models for the latest API

class RichFertilizerOrder {
  final String id;
  final String orderId;
  final String amount;
  final String status;
  final String createdAt;
  final String deliveryAddress;
  final String? paymentMode;

  final String farmerName;
  final String farmerPhone;
  final String farmerVillage;

  final List<OrderProductItem> products;

  RichFertilizerOrder({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    this.paymentMode,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerVillage,
    required this.products,
  });

  factory RichFertilizerOrder.fromJson(Map<String, dynamic> json) {
    final productsList = (json['products'] as List<dynamic>?) ?? [];
    final orderProducts = productsList
        .map((item) => OrderProductItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return RichFertilizerOrder(
      id: json['_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['created_at'] as String? ?? '',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      paymentMode: json['payment_mode'] as String?,
      farmerName: json['farmer_name'] as String? ?? 'Unknown Farmer',
      farmerPhone: json['farmer_phone'] as String? ?? '',
      farmerVillage: json['farmer_village'] as String? ?? '',
      products: orderProducts,
    );
  }

  String formatDate() {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

class OrderProductItem {
  final String id;
  final String quantity;
  final NestedProduct product;

  OrderProductItem({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory OrderProductItem.fromJson(Map<String, dynamic> json) {
    return OrderProductItem(
      id: json['id'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '1',
      product: NestedProduct.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}

class NestedProduct {
  final String productName;
  final String mrpPrice;
  final String sellPrice;
  final String productUnit;
  final String productQuantity;
  final String productCategory;
  final String? productDescriptions;
  final ProductDetail productDetails;
  final List<FertilizerImage> images;

  NestedProduct({
    required this.productName,
    required this.mrpPrice,
    required this.sellPrice,
    required this.productUnit,
    required this.productQuantity,
    required this.productCategory,
    this.productDescriptions,
    required this.productDetails,
    required this.images,
  });

  factory NestedProduct.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['images'] as List<dynamic>?) ?? [];
    final parsedImages = imagesList
        .map((img) => FertilizerImage.fromJson(img as Map<String, dynamic>))
        .toList();

    return NestedProduct(
      productName: json['product_name'] as String? ?? 'Unknown Product',
      mrpPrice: json['mrp_price'] as String? ?? '0',
      sellPrice: json['sell_price'] as String? ?? '0',
      productUnit: json['product_unit'] as String? ?? 'Unit',
      productQuantity: json['product_quantity'] as String? ?? '1',
      productCategory: json['product_category'] as String? ?? 'Unknown',
      productDescriptions: json['product_descriptions'] as String?,
      productDetails: ProductDetail.fromJson(
          json['product_details'] as Map<String, dynamic>? ?? {}),
      images: parsedImages,
    );
  }

  // Helpful computed properties
  double get sell => double.tryParse(sellPrice) ?? 0.0;
  double get mrp => double.tryParse(mrpPrice) ?? 0.0;
  String get unit => '$productQuantity ${_formatUnit(productUnit)}';

  static String _formatUnit(String unit) {
    final map = {
      'Ltr': 'Ltr',
      'ltr': 'Ltr',
      'Gm': 'Gm',
      'gm': 'Gm',
      'Kg': 'Kg',
      'kg': 'Kg',
      'Ml': 'ml',
      'ml': 'ml',
    };
    return map[unit.trim()] ?? unit.trim();
  }
}

class ProductDetail {
  final String content;
  final String usage;

  ProductDetail({required this.content, required this.usage});

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      content: json['content'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
    );
  }
}

// Response Wrappers

class FertilizerResponse {
  final String status;
  final String message;
  final List<Fertilizer> results;

  FertilizerResponse({
    required this.status,
    required this.message,
    required this.results,
  });

  factory FertilizerResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];

    final List<Fertilizer> fertilizers = [];

    if (rawResults is List) {
      for (final item in rawResults) {
        if (item is Map<String, dynamic>) {
          fertilizers.add(Fertilizer.fromJson(item));
        }
      }
    }

    return FertilizerResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      results: fertilizers,
    );
  }

  static FertilizerResponse fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    return FertilizerResponse.fromJson(decoded);
  }
}

class RichFertilizerOrderResponse {
  final String status;
  final String message;
  final List<RichFertilizerOrder> results;

  RichFertilizerOrderResponse({
    required this.status,
    required this.message,
    required this.results,
  });

  factory RichFertilizerOrderResponse.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>?) ?? [];

    return RichFertilizerOrderResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      results: resultsList
          .map((item) =>
              RichFertilizerOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Cart Models (kept as they were — still good!)
class CartItem {
  final String productId;
  final int quantity;
  final double totalValue;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.totalValue,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'totalValue': totalValue,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      totalValue: json['totalValue'] as double,
    );
  }
}

class Cart {
  final List<CartItem> items;
  final double totalCartValue;

  Cart({
    required this.items,
    required this.totalCartValue,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((item) => item.toJson()).toList(),
        'totalCartValue': totalCartValue,
      };

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCartValue: json['totalCartValue'] as double? ?? 0.0,
    );
  }
}
