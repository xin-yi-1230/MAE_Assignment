import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  List<String> _registeredIds = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<EventModel> get filteredEvents => _filteredEvents;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // All unique categories from events + "All"
  List<String> get categories {
    final cats = _allEvents.map((e) => e.category).toSet().toList();
    return ['All', ...cats];
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;

      // Get this user's registered event IDs
      final regSnap = await FirebaseFirestore.instance
          .collection('registrations')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Approved')
          .get();

      _registeredIds = regSnap.docs
          .map((d) => d.data()['eventId'] as String)
          .toList();

      // Get all events and mark isRegistered
      final events = await _eventService.getAllEvents();
      _allEvents = events
          .map((e) => e.copyWith(isRegistered: _registeredIds.contains(e.id)))
          .toList();

      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load events. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Called when user types in search bar
  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Called when user taps a category chip
  void onCategorySelected(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEvents = _allEvents.where((e) {
      // Category filter
      final matchesCategory =
          _selectedCategory == 'All' || e.category == _selectedCategory;

      // Search filter — checks name and location
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.location.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }
}
