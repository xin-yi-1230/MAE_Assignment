import 'package:flutter/material.dart';
import '../services/review_service.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  int _selectedStars = 0;
  String _comment = '';
  bool _isLoading = false;
  bool _isSubmitted = false;
  String? _errorMessage;

  int get selectedStars => _selectedStars;
  String get comment => _comment;
  bool get isLoading => _isLoading;
  bool get isSubmitted => _isSubmitted;
  String? get errorMessage => _errorMessage;
  bool get canSubmit => _selectedStars > 0;

  void onStarTapped(int star) {
    _selectedStars = star;
    notifyListeners();
  }

  void onCommentChanged(String text) {
    _comment = text;
    notifyListeners();
  }

  Future<void> submitReview({
    required String boothId,
    required String eventId,
    required String orderId,
  }) async {
    if (_selectedStars == 0) {
      _errorMessage = 'Please select a star rating';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        _errorMessage = 'No active user found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Save review
      await _reviewService.submitReview(
        userId: userId,
        boothId: boothId,
        eventId: eventId,
        stars: _selectedStars,
        comment: _comment,
      );

      // Mark order as reviewed
      await _orderService.markAsReviewed(orderId);

      _isSubmitted = true;
    } catch (e) {
      _errorMessage = 'Failed to submit review. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _selectedStars = 0;
    _comment = '';
    _isLoading = false;
    _isSubmitted = false;
    _errorMessage = null;
    notifyListeners();
  }
}
