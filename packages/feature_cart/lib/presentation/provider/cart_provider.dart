import 'package:flutter/foundation.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

/// Provider implementation using ChangeNotifier
/// This is the simplest state management approach
class CartProvider extends ChangeNotifier {
  final CartRepository _repository;

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider(this._repository) {
    loadCart();
  }

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;

  /// Load cart from repository
  Future<void> loadCart() async {
    _setLoading(true);
    try {
      _items = await _repository.getCartItems();
      _clearError();
    } catch (e) {
      _setError('Failed to load cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add item to cart
  Future<void> addItem(CartItem item) async {
    _setLoading(true);
    try {
      await _repository.addToCart(item);
      await loadCart(); // Reload from repository
      _clearError();
    } catch (e) {
      _setError('Failed to add item: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String productId) async {
    _setLoading(true);
    try {
      await _repository.removeFromCart(productId);
      await loadCart();
      _clearError();
    } catch (e) {
      _setError('Failed to remove item: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    _setLoading(true);
    try {
      await _repository.updateQuantity(productId, quantity);
      await loadCart();
      _clearError();
    } catch (e) {
      _setError('Failed to update quantity: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    _setLoading(true);
    try {
      await _repository.clearCart();
      _items = [];
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
