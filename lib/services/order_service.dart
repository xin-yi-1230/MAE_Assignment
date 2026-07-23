import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get orders for a specific user
  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final snap = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs.map((d) => OrderModel.fromJson(d.id, d.data())).toList();
  }

  // Place a new order from cart items
  Future<String> placeOrder({
    required String userId,
    required String boothId,
    required String boothName,
    required String eventId,
    required String eventName,
    required List<CartItemModel> items,
    required String pickupTime,
  }) async {
    final totalPrice = items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final docRef = await _db.collection('orders').add({
      'userId': userId,
      'boothId': boothId,
      'boothName': boothName,
      'eventId': eventId,
      'eventName': eventName,
      'items': items.map((i) => i.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': 'Pending',
      'qrCode': 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toString(),
      //'createdAt': FieldValue.serverTimestamp(),
      'pickupTime': pickupTime,
      'isReviewed': false,
    });
    return docRef.id;
  }

  // Update order isReviewed flag after review submitted
  Future<void> markAsReviewed(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'isReviewed': true});
  }
}
