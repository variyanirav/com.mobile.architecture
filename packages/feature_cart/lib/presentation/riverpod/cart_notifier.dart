import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

/// StateNotifier for Riverpod pattern
/// Manages cart state in an immutable way
class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super(const CartState()) {
    loadCart();
  }

  /// Load cart from repository
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);

    try {
      final items = await _repository.getCartItems();
      state = state.copyWith(items: items, isLoading: false).clearError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load cart: $e',
      );
    }
  }

  /// Add item to cart
  Future<void> addItem(CartItem item) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.addToCart(item);
      final items = await _repository.getCartItems();
      state = state.copyWith(items: items, isLoading: false).clearError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add item: $e',
      );
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String productId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.removeFromCart(productId);
      final items = await _repository.getCartItems();
      state = state.copyWith(items: items, isLoading: false).clearError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to remove item: $e',
      );
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.updateQuantity(productId, quantity);
      final items = await _repository.getCartItems();
      state = state.copyWith(items: items, isLoading: false).clearError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update quantity: $e',
      );
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.clearCart();
      state = state.copyWith(items: [], isLoading: false).clearError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to clear cart: $e',
      );
    }
  }
}
