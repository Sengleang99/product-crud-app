// lib/presentation/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:product_app/data/models/product.dart';
import 'package:product_app/data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  List<Product> _products = [];
  List<Product> _filteredProducts = []; // This list is shown in UI
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _error = '';
  bool _hasMoreProducts = true; // For pagination

  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  ProductProvider({required this.repository});

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get error => _error;
  bool get hasMoreProducts => _hasMoreProducts;

  // --- Data Loading and Manipulation ---

  Future<void> loadProducts({bool isRefresh = false}) async {
    if (!isRefresh) { // Show loading indicator only for initial load, not for refresh
      _isLoading = true;
      _error = ''; // Clear previous errors
      notifyListeners();
    }

    try {
      // Always fetch from page 1 for a full refresh
      final fetchedProducts = await repository.getProducts(page: 1, limit: 10);
      _products = fetchedProducts;
      _hasMoreProducts = fetchedProducts.length == 10; // Adjust based on your API's pagination logic

      _applySearchAndSort(); // Apply existing search/sort
    } catch (e) {
      _error = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify all listeners about the new data or error
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreProducts) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = (_products.length ~/ 10) + 1; // Calculate next page
      final newProducts = await repository.getProducts(page: nextPage, limit: 10);

      if (newProducts.isEmpty) {
        _hasMoreProducts = false;
      } else {
        _products.addAll(newProducts);
      }
      _applySearchAndSort();
    } catch (e) {
      _error = 'Failed to load more products: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      final newProduct = await repository.addProduct(product);
      _products.insert(0, newProduct); // Add new product to the top
      _applySearchAndSort(); // Re-apply search/sort
      notifyListeners(); // IMPORTANT: Notify listeners after adding
      return true;
    } catch (e) {
      _error = 'Failed to add product: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final updatedProduct = await repository.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _applySearchAndSort();
        notifyListeners(); // IMPORTANT: Notify listeners after updating
      }
      return true;
    } catch (e) {
      _error = 'Failed to update product: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _applySearchAndSort();
      notifyListeners(); // IMPORTANT: Notify listeners after deleting
    } catch (e) {
      _error = 'Failed to delete product: $e';
      notifyListeners();
    }
  }

  // --- Search and Sort Logic ---

  void searchProducts(String query) {
    _searchQuery = query;
    _applySearchAndSort();
    notifyListeners();
  }

  void sortProducts(String sortBy, bool ascending) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applySearchAndSort();
    notifyListeners();
  }

  void _applySearchAndSort() {
    List<Product> tempProducts = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    tempProducts.sort((a, b) {
      dynamic aValue, bValue;
      switch (_sortBy) {
        case 'name':
          aValue = a.name.toLowerCase();
          bValue = b.name.toLowerCase();
          break;
        case 'price':
          aValue = a.price;
          bValue = b.price;
          break;
        case 'stock':
          aValue = a.stock;
          bValue = b.stock;
          break;
        default: // Default to sorting by name
          aValue = a.name.toLowerCase();
          bValue = b.name.toLowerCase();
      }

      return _sortAscending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    _filteredProducts = tempProducts;
  }
}