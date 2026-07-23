class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String boothId;
  final String boothName;
  final String eventId;
  final double price;
  int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.boothId,
    required this.boothName,
    required this.eventId,
    required this.price,
    required this.quantity,
  });

  // formatted price per item
  String get formattedPrice => 'RM ${price.toStringAsFixed(2)}';

  // formatted subtotal for this item
  String get formattedSubtotal => 'RM ${(price * quantity).toStringAsFixed(2)}';

  double get subtotal => price * quantity;

  factory CartItemModel.fromJson(String id, Map<String, dynamic> json) {
    return CartItemModel(
      id: id,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      boothId: json['boothId'] ?? '',
      boothName: json['boothName'] ?? '',
      eventId: json['eventId'] ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'boothId': boothId,
    'boothName': boothName,
    'eventId': eventId,
    'price': price,
    'quantity': quantity,
  };
}
