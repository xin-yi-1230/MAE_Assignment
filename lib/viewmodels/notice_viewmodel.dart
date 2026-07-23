import 'package:flutter/material.dart';
import '../models/notice_model.dart';
import '../services/notice_service.dart';

class NoticeViewModel extends ChangeNotifier {
  final NoticeService _noticeService = NoticeService();

  List<NoticeModel> _allNotices = [];
  List<NoticeModel> _filteredNotices = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  List<NoticeModel> get filteredNotices => _filteredNotices;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _allNotices.length;

  final List<String> filters = ['All', 'General', 'Student', 'Seller'];

  Future<void> loadNotices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // student role hardcoded for now
      // replace with authService.currentUserRole after login
      _allNotices = await _noticeService.getNotices('student');
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load notices. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void onFilterChanged(String filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<NoticeModel> result = _allNotices;

    // Filter by role
    if (_selectedFilter != 'All') {
      final role = _selectedFilter.toLowerCase();
      result = result
          .where((n) => n.targetRole == role || n.targetRole == 'all')
          .toList();
    }

    // Search by title or body
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where(
            (n) =>
                n.title.toLowerCase().contains(query) ||
                n.body.toLowerCase().contains(query),
          )
          .toList();
    }

    _filteredNotices = result;
  }
}
