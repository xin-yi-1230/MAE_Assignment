import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  String _selectedStatus = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get filteredOrders => _filteredOrders;
  String get selectedStatus => _selectedStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get statusFilters => [
    'All',
    'Pending',
    'Confirmed',
    'Ready',
    'Collected',
  ];

  // Total active orders count (not collected)
  int get activeOrderCount =>
      _allOrders.where((o) => o.status != 'Collected').length;

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return;
      }
      _allOrders = await _orderService.getOrdersByUser(userId);
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Failed to load orders. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void onStatusChanged(String status) {
    _selectedStatus = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filteredOrders = _selectedStatus == 'All'
        ? _allOrders
        : _allOrders.where((o) => o.status == _selectedStatus).toList();
  }

  // Called after review submitted
  void markOrderAsReviewed(String orderId) {
    final index = _allOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _allOrders[index] = OrderModel(
        id: _allOrders[index].id,
        userId: _allOrders[index].userId,
        boothId: _allOrders[index].boothId,
        boothName: _allOrders[index].boothName,
        eventId: _allOrders[index].eventId,
        eventName: _allOrders[index].eventName,
        items: _allOrders[index].items,
        totalPrice: _allOrders[index].totalPrice,
        status: _allOrders[index].status,
        qrCode: _allOrders[index].qrCode,
        createdAt: _allOrders[index].createdAt,
        pickupTime: _allOrders[index].pickupTime,
        isReviewed: true,
      );
      _applyFilter();
      notifyListeners();
    }
  }
}
