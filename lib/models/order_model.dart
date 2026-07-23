import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemDetail {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  String get formattedPrice => 'RM ${price.toStringAsFixed(2)}';

  String get formattedSubtotal => 'RM ${(price * quantity).toStringAsFixed(2)}';

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String boothId;
  final String boothName;
  final String eventId;
  final String eventName;
  final List<OrderItemDetail> items;
  final double totalPrice;
  final String status;
  final String qrCode;
  final String createdAt;
  final String pickupTime;
  final bool isReviewed;

  OrderModel({
    required this.id,
    required this.userId,
    required this.boothId,
    required this.boothName,
    required this.eventId,
    required this.eventName,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.qrCode,
    required this.createdAt,
    required this.pickupTime,
    this.isReviewed = false,
  });

  // ── Formatting getters ────────────────────────
  String get formattedTotal => 'RM ${totalPrice.toStringAsFixed(2)}';

  // Show review button only when collected and not yet reviewed
  bool get canReview => status == 'Collected' && !isReviewed;

  factory OrderModel.fromJson(String id, Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: id,
      userId: json['userId'] ?? '',
      boothId: json['boothId'] ?? '',
      boothName: json['boothName'] ?? '',
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      items: rawItems
          .map((i) => OrderItemDetail.fromJson(i as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] ?? '',
      qrCode: json['qrCode'] ?? '',
      createdAt: json['createdAt'] ?? '',
      pickupTime: json['pickupTime'] ?? '',
      isReviewed: json['isReviewed'] ?? false,
    );
  }
}
