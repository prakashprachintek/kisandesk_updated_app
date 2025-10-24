import 'dart:convert';

class Fertilizer {
  final String id;
  final String productName;
  final String amount;
  final String discount;
  final String quantity;
  final String productId;
  final List<FertilizerImage> images;
  final bool isDeleted;
  final String createdAt;
  final String createdBy;

  Fertilizer({
    required this.id,
    required this.productName,
    required this.amount,
    required this.discount,
    required this.quantity,
    required this.productId,
    required this.images,
    required this.isDeleted,
    required this.createdAt,
    required this.createdBy,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    return Fertilizer(
      id: json['_id'] as String,
      productName: json['product_name'] as String,
      amount: json['amount'] as String,
      discount: json['discount'] as String,
      quantity: json['quantity'] as String,
      productId: json['product_id'] as String,
      images: (json['images'] as List<dynamic>)
          .map((image) => FertilizerImage.fromJson(image))
          .toList(),
      isDeleted: json['is_deleted'] as bool,
      createdAt: json['created_at'] as String,
      createdBy: json['created_by'] as String,
    );
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
      fileName: json['fileName'] as String,
      url: json['url'] as String,
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
      action: json['action'] as String,
      actionAt: json['action_at'] as String,
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