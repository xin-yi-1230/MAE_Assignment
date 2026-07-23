import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  bool _orderPlaced = false;
  String? _errorMessage;
  String? _lastOrderId;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get orderPlaced => _orderPlaced;
  String? get errorMessage => _errorMessage;
  String? get lastOrderId => _lastOrderId;
  bool get isEmpty => _items.isEmpty;

  // Total item count across all cart items
  int get totalItemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  // Total price
  double get totalPrice => _items.fold(0, (sum, i) => sum + i.subtotal);

  String get formattedTotal => 'RM ${totalPrice.toStringAsFixed(2)}';

  // Group items by booth
  Map<String, List<CartItemModel>> get itemsByBooth {
    final Map<String, List<CartItemModel>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.boothName, () => []).add(item);
    }
    return grouped;
  }

  // ── Load cart ─────────────────────────────────
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return;
      }

      _items = await _cartService.getCartItems(userId);
    } catch (e) {
      _errorMessage = 'Failed to load cart.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Add to cart ───────────────────────────────
  Future<void> addToCart(
    ProductModel product,
    int quantity,
    String boothName,
    String eventId,
  ) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        _errorMessage = 'No active user found.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      await _cartService.addToCart(
        userId,
        product,
        quantity,
        boothName,
        eventId,
      );
      await loadCart(); // refresh
    } catch (e) {
      _errorMessage = 'Failed to add item to cart.';
      notifyListeners();
    }
  }

  // ── Update quantity ───────────────────────────
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        _errorMessage = 'No active user found.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      if (quantity <= 0) {
        await _cartService.removeItem(userId, cartItemId);
      } else {
        await _cartService.updateQuantity(userId, cartItemId, quantity);
      }
      await loadCart();
    } catch (e) {
      _errorMessage = 'Failed to update quantity.';
      notifyListeners();
    }
  }

  // ── Remove item ───────────────────────────────
  Future<void> removeItem(String cartItemId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        _errorMessage = 'No active user found.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      await _cartService.removeItem(userId, cartItemId);
      await loadCart();
    } catch (e) {
      _errorMessage = 'Failed to remove item.';
      notifyListeners();
    }
  }

  // ── Place order ───────────────────────────────
  Future<void> placeOrder({
    required String boothId,
    required String boothName,
    required String eventId,
    required String eventName,
    required String pickupTime,
  }) async {
    if (_items.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _orderPlaced = false;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        _errorMessage = 'No active user found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _lastOrderId = await _orderService.placeOrder(
        userId: userId,
        boothId: boothId,
        boothName: boothName,
        eventId: eventId,
        eventName: eventName,
        items: _items,
        pickupTime: pickupTime,
      );

      // Clear cart after successful order
      await _cartService.clearCart(userId);
      _items = [];
      _orderPlaced = true;
    } catch (e) {
      _errorMessage = 'Failed to place order. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetOrderPlaced() {
    _orderPlaced = false;
    notifyListeners();
  }
}
