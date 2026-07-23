import 'package:flutter/material.dart';
import '../models/booth_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../services/booth_service.dart';

class BoothViewModel extends ChangeNotifier {
  final BoothService _boothService = BoothService();

  // ── Booth List state ─────────────────────────
  List<BoothModel> _allBooths = [];
  List<BoothModel> _filteredBooths = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // ── Booth Detail state ───────────────────────
  BoothModel? _selectedBooth;
  List<ProductModel> _products = [];
  List<ReviewModel> _reviews = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _menuSortBy =
      'Default'; // 'Default' / 'Price: Low to High' / 'Price: High to Low' / 'Name'
  String _menuFilterStatus = 'All'; // 'All' / 'Available' / 'Low' / 'Sold Out'
  List<ProductModel> _filteredProducts = [];

  // ── Getters ──────────────────────────────────
  List<BoothModel> get filteredBooths => _filteredBooths;
  List<ProductModel> get products => _products;
  List<ReviewModel> get reviews => _reviews;
  BoothModel? get selectedBooth => _selectedBooth;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories {
    final cats = _allBooths.map((b) => b.category).toSet().toList();
    return ['All', ...cats];
  }

  List<ProductModel> get filteredProducts => _filteredProducts;
  String get menuSortBy => _menuSortBy;
  String get menuFilterStatus => _menuFilterStatus;

  // ── Load all booths for an event ─────────────
  Future<void> loadBooths(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allBooths = await _boothService.getBoothsByEvent(eventId);
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load booths. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load single booth detail + products + reviews ──
  Future<void> loadBoothDetail(String boothId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedBooth = await _boothService.getBoothById(boothId);
      _products = await _boothService.getProductsByBooth(boothId);
      _reviews = await _boothService.getReviewsByBooth(boothId);
      _applyMenuFilters();
    } catch (e) {
      _errorMessage = 'Failed to load booth details.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Search ────────────────────────────────────
  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ── Category filter ───────────────────────────
  void onCategorySelected(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredBooths = _allBooths.where((b) {
      final matchesCategory =
          _selectedCategory == 'All' || b.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          b.name.toLowerCase().contains(query) ||
          b.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void onMenuSortChanged(String sortBy) {
    _menuSortBy = sortBy;
    _applyMenuFilters();
    notifyListeners();
  }

  void onMenuFilterChanged(String status) {
    _menuFilterStatus = status;
    _applyMenuFilters();
    notifyListeners();
  }

  void _applyMenuFilters() {
    // Step 1 — filter by status
    _filteredProducts = _products.where((p) {
      if (_menuFilterStatus == 'All') return true;
      return p.status == _menuFilterStatus;
    }).toList();

    // Step 2 — sort
    switch (_menuSortBy) {
      case 'Price: Low to High':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name':
        _filteredProducts.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      default:
        break; // Default — keep original Firestore order
    }
  }
}
