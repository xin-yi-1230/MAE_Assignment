import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String boothId;
  final String eventId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String status;

  ProductModel({
    required this.id,
    required this.boothId,
    required this.eventId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.status,
  });

  // ── Formatting getters ────────────────────────

  // "RM 8.50"
  String get formattedPrice => 'RM ${price.toStringAsFixed(2)}';

  // Stock status label
  String get stockLabel {
    if (stock == 0) return 'Sold Out';
    if (stock <= 10) return 'Low Stock ($stock left)';
    return 'In Stock';
  }

  bool get isAvailable => status != 'Sold Out' && stock > 0;

  // ── fromJson ──────────────────────────────────
  factory ProductModel.fromJson(String id, Map<String, dynamic> json) {
    return ProductModel(
      id: id,
      boothId: json['boothId'] ?? '',
      eventId: json['eventId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
