import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/registration_service.dart';

class EventDetailViewModel extends ChangeNotifier {
  final RegistrationService _regService = RegistrationService();
  final AuthService _authService = AuthService();

  bool _isRegistered = false;
  bool _isLoading = false;
  bool _registerSuccess = false;
  String? _errorMessage;

  bool get isRegistered => _isRegistered;
  bool get isLoading => _isLoading;
  bool get registerSuccess => _registerSuccess;
  String? get errorMessage => _errorMessage;

  // Check registration status when screen opens
  Future<void> checkRegistration(String eventId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return;
    }
    _isRegistered = await _regService.isRegistered(userId, eventId);
    notifyListeners();
  }

  // Register button tapped
  Future<void> registerForEvent(String eventId) async {
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
      await _regService.registerForEvent(userId, eventId);
      _isRegistered = true;
      _registerSuccess = true;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
