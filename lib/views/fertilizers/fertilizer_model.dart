import 'dart:convert';

class Fertilizer {
  final String id;
  final String productName;
  final String mrpPrice;
  final String sellPrice;
  final String productQuantity;   // e.g., "1", "500"
  final String productUnit;       // e.g., "Ltr", "Gm"
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
  String get unit => '$productQuantity ${_formatUnit(productUnit)}'; // "500 Gm", "1 Ltr"
  double get mrp => double.tryParse(mrpPrice) ?? 0.0;
  double get sell => double.tryParse(sellPrice) ?? 0.0;
  double get discountPercent => mrp > 0 ? ((mrp - sell) / mrp) * 100 : 0.0;
  String get specialDiscount => discountPercent > 0 ? '${discountPercent.toStringAsFixed(0)}%' : '0%';
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
      images.addAll(imgData.map((i) => FertilizerImage.fromJson(i as Map<String, dynamic>)));
    }

    // Parse activity log
    final List<ActivityLog> logs = [];
    final logData = json['activity_log'];
    if (logData is List) {
      logs.addAll(logData.map((l) => ActivityLog.fromJson(l as Map<String, dynamic>)));
    }

    // Parse reviews
    final List<Review> reviews = [];
    final reviewData = json['reviews'];
    if (reviewData is List) {
      reviews.addAll(reviewData.map((r) => Review.fromJson(r as Map<String, dynamic>)));
    }

    return Fertilizer(
      id: json['_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Unknown Product',
      mrpPrice: (json['mrp_price'] as String?) ?? '0',
      sellPrice: (json['sell_price'] as String?) ?? '0',
      productQuantity: (json['product_quantity'] as String?) ?? '1',
      productUnit: (json['product_unit'] as String?) ?? 'Unit',
      productId: json['product_id'] as String? ?? '',
      soldQuantity: (json['sold_quantity'] as String?) ?? '0',
      availableQuantity: _parseIntSafe(json['available_quantity']),
      status: json['product_status'] as String? ?? 'Unknown',
      images: images,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: (json['created_at'] as String?) ?? '',
      createdBy: (json['created_by'] as String?) ?? '',
      activityLog: logs.isNotEmpty ? logs : null,
      category: json['product_category'] as String? ?? 'Unknown',
      description: json['product_descriptions'] as String?,
      productDetails: json['product_details'] != null
          ? ProductDetails.fromJson(json['product_details'] as Map<String, dynamic>)
          : null,
      reviews: reviews.isNotEmpty ? reviews : null,
    );
  }

  // Format unit properly
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

// Supporting Classes
class FertilizerImage {
  final String fileName;
  final String url;

  FertilizerImage({required this.fileName, required this.url});

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

// Response Wrapper
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
    return FertilizerResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => Fertilizer.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static FertilizerResponse fromJsonString(String jsonString) {
    return FertilizerResponse.fromJson(jsonDecode(jsonString));
  }
}

// Keep all your other models (Cart, Order, etc.) — they are perfect!
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

// Order models (unchanged — perfect as is)
class OrderProduct {
  final String id;
  final String quantity;

  OrderProduct({required this.id, required this.quantity});

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] as String,
      quantity: json['quantity'] as String,
    );
  }
}

class FertilizerOrder {
  final String id;
  final String farmerId;
  final List<OrderProduct> products;
  final String orderId;
  final String amount;
  final String? paymentMode;
  final String status;
  final List<ActivityLog> activityLog;

  FertilizerOrder({
    required this.id,
    required this.farmerId,
    required this.products,
    required this.orderId,
    required this.amount,
    required this.paymentMode,
    required this.status,
    required this.activityLog,
  });

  factory FertilizerOrder.fromJson(Map<String, dynamic> json) {
    List<OrderProduct> products = [];
    final productData = json['product_id'];
    if (productData is List) {
      products = productData.map((item) => OrderProduct.fromJson(item)).toList();
    } else if (productData is String) {
      products = [OrderProduct(id: productData, quantity: '1')];
    }

    return FertilizerOrder(
      id: json['_id'] as String,
      farmerId: json['farmer_id'] as String,
      products: products,
      orderId: json['order_id'] as String,
      amount: json['amount'] as String,
      paymentMode: json['payment_mode'] as String?,
      status: json['status'] as String,
      activityLog: (json['activity_log'] as List<dynamic>? ?? [])
          .map((log) => ActivityLog.fromJson(log as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FertilizerOrderResponse {
  final String status;
  final String message;
  final List<FertilizerOrder> results;

  FertilizerOrderResponse({
    required this.status,
    required this.message,
    required this.results,
  });

  factory FertilizerOrderResponse.fromJson(Map<String, dynamic> json) {
    return FertilizerOrderResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => FertilizerOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}