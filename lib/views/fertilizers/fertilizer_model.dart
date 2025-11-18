import 'dart:convert';

class Fertilizer {
  final String id;
  final String productName;
  final String mrpPrice;        // mrp_price
  final String sellPrice;       // sell_price (we'll use this as main price)
  final String specialDiscount; // special_discount (e.g., "10%", "0%")
  final String unit;            // unit (e.g., "1 ltr", "500 gm")
  final String productId;
  final String soldQuantity;
  final int totalQuantity;      // available stock
  final String status;          // "Active", etc.
  final List<FertilizerImage> images;
  final bool isDeleted;
  final String createdAt;
  final String createdBy;
  final List<ActivityLog>? activityLog;
  final String category;
  final String? description;    // sometimes "discription", sometimes "description"
  final String? spacialDiscount; // typo in API: "spacial_discount"

  // Computed helpers (optional, but super useful)
  String get displayPrice => sellPrice;
  String get displayDiscount => specialDiscount;
  String get displayUnit => unit;
  int get availableStock => totalQuantity;

  Fertilizer({
    required this.id,
    required this.productName,
    required this.mrpPrice,
    required this.sellPrice,
    required this.specialDiscount,
    required this.unit,
    required this.productId,
    required this.soldQuantity,
    required this.totalQuantity,
    required this.status,
    required this.images,
    required this.isDeleted,
    required this.createdAt,
    required this.createdBy,
    this.activityLog,
    required this.category,
    this.description,
    this.spacialDiscount,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    // Safely parse images
    final List<FertilizerImage> images = [];
    final dynamic imgData = json['images'];
    if (imgData is List) {
      images.addAll(imgData.map((i) => FertilizerImage.fromJson(i as Map<String, dynamic>)));
    }

    // Safely parse activity log
    final List<ActivityLog> logs = [];
    final dynamic logData = json['activity_log'];
    if (logData is List) {
      logs.addAll(logData.map((l) => ActivityLog.fromJson(l as Map<String, dynamic>)));
    }

    return Fertilizer(
      id: json['_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Unknown Product',
      mrpPrice: (json['mrp_price'] as String?) ?? '0',
      sellPrice: (json['sell_price'] as String?) ?? (json['mrp_price'] as String?) ?? '0',
      specialDiscount: _normalizeDiscount(json['special_discount'] as String?),
      unit: json['unit'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      soldQuantity: (json['sold_quantity'] as String?) ?? '0',
      totalQuantity: _parseIntSafe(json['total_quantity']),
      status: json['status'] as String? ?? 'Unknown',
      images: images,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      createdAt: (json['created_at'] as String?) ?? '',
      createdBy: (json['created_by'] as String?) ?? '',
      activityLog: logs.isNotEmpty ? logs : null,
      category: json['category'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? json['discription'] as String?,
      spacialDiscount: json['spacial_discount'] as String?,
    );
  }

  // Helper: make sure discount always ends with %
  static String _normalizeDiscount(String? discount) {
    if (discount == null || discount.isEmpty) return '0%';
    final trimmed = discount.trim();
    return trimmed.endsWith('%') ? trimmed : '$trimmed%';
  }

  // Helper: safely parse int (can be String or int in JSON)
  static int _parseIntSafe(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Optional: calculate discounted price (same logic you already use)
  double get discountedPrice {
    final original = double.tryParse(sellPrice) ?? 0.0;
    final discountStr = specialDiscount.replaceAll('%', '');
    final discountPercent = double.tryParse(discountStr) ?? 0.0;
    return original * (1 - discountPercent / 100);
  }
}

class FertilizerImage {
  final String fileName;
  final String url;

  FertilizerImage({
    required this.fileName,
    required this.url,
  });

  factory FertilizerImage.fromJson(Map<String, dynamic> json) {
    return FertilizerImage(
      fileName: json['fileName'] as String? ?? 'image.jpg',
      url: json['url'] as String? ?? '',
    );
  }
}

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
      status: json['status'] as String,
      message: json['message'] as String,
      results: (json['results'] as List<dynamic>)
          .map((item) => Fertilizer.fromJson(item))
          .toList(),
    );
  }

  static FertilizerResponse fromJsonString(String jsonString) {
    return FertilizerResponse.fromJson(jsonDecode(jsonString));
  }
}

class ActivityLog {
  final String action;
  final String actionAt;

  ActivityLog({
    required this.action,
    required this.actionAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      action: json['action'] as String? ?? '',
      actionAt: json['action_at'] as String? ?? '',
    );
  }
}

class OrderProduct {
  final String id;
  final String quantity;

  OrderProduct({
    required this.id,
    required this.quantity,
  });

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
    List<OrderProduct> products;
    final productId = json['product_id'];
    if (productId is List<dynamic>) {
      products = productId.map((item) => OrderProduct.fromJson(item)).toList();
    } else if (productId is String) {
      products = [OrderProduct(id: productId, quantity: '1')];
    } else {
      products = [];
    }

    return FertilizerOrder(
      id: json['_id'] as String,
      farmerId: json['farmer_id'] as String,
      products: products,
      orderId: json['order_id'] as String,
      amount: json['amount'] as String,
      paymentMode: json['payment_mode'] as String?,
      status: json['status'] as String,
      activityLog: (json['activity_log'] as List<dynamic>)
          .map((log) => ActivityLog.fromJson(log))
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
      status: json['status'] as String,
      message: json['message'] as String,
      results: (json['results'] as List<dynamic>)
          .map((item) => FertilizerOrder.fromJson(item))
          .toList(),
    );
  }

  static FertilizerOrderResponse fromJsonString(String jsonString) {
    return FertilizerOrderResponse.fromJson(jsonDecode(jsonString));
  }
}

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
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalCartValue: json['totalCartValue'] as double,
    );
  }
}