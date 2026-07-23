import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/order_model.dart';
import '../models/registration_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/order_service.dart';
import '../services/registration_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final EventService _eventService = EventService();
  final OrderService _orderService = OrderService();

  List<EventModel> _events = [];
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _username = '';
  String _email = '';
  String _role = '';
  String _studentID = '';
  String _photoUrl = '';
  bool _updateSuccess = false;

  String get email => _email;
  String get role => _role;
  String get studentID => _studentID;
  String get photoUrl => _photoUrl;
  bool get updateSuccess => _updateSuccess;
  List<EventModel> get events => _events;
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get username => _username;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;

      if (userId == null) {
        return;
      }

      // Load username from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      _username = userDoc.data()?['name'] ?? 'Student';
      _email = userDoc.data()?['email'] ?? '';
      _role = userDoc.data()?['role'] ?? '';
      _studentID = userDoc.data()?['uid'] ?? '';
      _photoUrl = userDoc.data()?['photoUrl'] ?? '';

      // Load registered event IDs for this user
      final regSnap = await FirebaseFirestore.instance
          .collection('registrations')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Approved')
          .get();

      final registeredEventIds = regSnap.docs
          .map((d) => d.data()['eventId'] as String)
          .toList();

      // Load all events then filter to registered ones
      // and mark isRegistered = true
      final allEvents = await _eventService.getAllEvents();
      _events = allEvents
          .where((e) => registeredEventIds.contains(e.id))
          .map((e) => e.copyWith(isRegistered: true))
          .toList();

      // Load orders for this user
      _orders = await _orderService.getOrdersByUser(userId);
    } catch (e) {
      _errorMessage = 'Failed to load dashboard. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String username,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _updateSuccess = false;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'No active user found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 1. If email changed, update it in Firebase Auth login credentials
      if (email.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(email.trim());
      }

      // 2. Update Firestore user document using 'name'
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'name': username, 'email': email.trim()},
      );

      _username = username;
      _email = email.trim();
      _updateSuccess = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _errorMessage =
            'Please log in again before changing your email address.';
      } else {
        _errorMessage = e.message ?? 'Failed to update email.';
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _updateSuccess = false; // Reset status flag before updating
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _errorMessage = 'No active user found. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 🔐 Call Firebase Authentication to change the password
      await user.updatePassword(newPassword);
      _updateSuccess = true;
    } on FirebaseAuthException catch (e) {
      // Handle common Firebase Auth password change errors
      if (e.code == 'requires-recent-login') {
        _errorMessage =
            'For security reasons, please log out and log in again before changing your password.';
      } else if (e.code == 'weak-password') {
        _errorMessage = 'The password provided is too weak.';
      } else {
        _errorMessage = e.message ?? 'Failed to update password.';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add reset method
  void resetUpdateSuccess() {
    _updateSuccess = false;
    notifyListeners();
  }
}
  // Future<void> loadEvents() async {
  //   _isLoading = true;
  //   _errorMessage = null; // Clear previous errors on retry
  //   notifyListeners();

  //   try {
  //     // Call the service, which might throw an exception
  //     _events = await _eventService.getEvents();
  //   } catch (error) {
  //     // 🛡️ Catch the exception thrown by the service here!
  //     _errorMessage = error.toString();
  //     _events = []; // Clear current list on error if desired
  //   } finally {
  //     // This block ALWAYS runs whether the try succeeded or failed
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
  // // ── Mock data (swap with Firebase calls later) ──
  // final List<EventModel> _events = [
  //   EventModel(id: '1', name: 'Food Fair',      icon: '🍽️', location: 'Block A Foyer', date: '1 June 2026'),
  //   EventModel(id: '2', name: 'Tech Bazaar',    icon: '💻', location: 'Block B Hall',  date: '1 June 2026'),
  //   EventModel(id: '3', name: 'Cultural Night', icon: '🎭', location: 'Auditorium',    date: '2 June 2026'),
  // ];

  // final List<OrderModel> _orders = [
  //   OrderModel(id: '1', boothName: 'Nasi Lemak Lab',  itemName: 'Nasi Lemak Ayam Goreng Berempah', date: '1 June 2026', quantity: 1, status: 'Confirmed'),
  //   OrderModel(id: '2', boothName: 'Bubble Story',    itemName: 'Brown Sugar Milk Tea (L)',         date: '1 June 2026', quantity: 2, status: 'Ready'),
  // ];

