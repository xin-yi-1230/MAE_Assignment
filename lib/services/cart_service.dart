import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to user's cart subcollection
  CollectionReference _cartRef(String userId) =>
      _db.collection('cart').doc(userId).collection('items');

  // Get all cart items for user
  Future<List<CartItemModel>> getCartItems(String userId) async {
    final snap = await _cartRef(userId).get();
    return snap.docs
        .map(
          (d) => CartItemModel.fromJson(d.id, d.data() as Map<String, dynamic>),
        )
        .toList();
  }

  // Add item to cart or increase quantity if exists
  Future<void> addToCart(
    String userId,
    ProductModel product,
    int quantity,
    String boothName,
    String eventId,
  ) async {
    // Check if product already in cart
    final existing = await _cartRef(
      userId,
    ).where('productId', isEqualTo: product.id).get();

    if (existing.docs.isNotEmpty) {
      // Already in cart — increase quantity
      final doc = existing.docs.first;
      final oldQty = (doc.data() as Map)['quantity'] as int;
      await _cartRef(
        userId,
      ).doc(doc.id).update({'quantity': oldQty + quantity});
    } else {
      // New item — add to cart
      await _cartRef(userId).add({
        'productId': product.id,
        'productName': product.name,
        'boothId': product.boothId,
        'boothName': boothName,
        'eventId': eventId,
        'price': product.price,
        'quantity': quantity,
      });
    }
  }

  // Update quantity of a cart item
  Future<void> updateQuantity(
    String userId,
    String cartItemId,
    int quantity,
  ) async {
    await _cartRef(userId).doc(cartItemId).update({'quantity': quantity});
  }

  // Remove item from cart
  Future<void> removeItem(String userId, String cartItemId) async {
    await _cartRef(userId).doc(cartItemId).delete();
  }

  // Clear entire cart
  Future<void> clearCart(String userId) async {
    final snap = await _cartRef(userId).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
