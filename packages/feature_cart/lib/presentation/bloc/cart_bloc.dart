import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// BLoC for managing cart state using event-driven architecture
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  CartBloc(this._repository) : super(const CartInitial()) {
    on<CartLoadRequested>(_onLoadRequested);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityUpdated>(_onItemQuantityUpdated);
    on<CartCleared>(_onCleared);

    // Auto-load cart on initialization
    add(const CartLoadRequested());
  }

  /// Handle load cart event
  Future<void> _onLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());

    try {
      final items = await _repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('Failed to load cart: $e'));
    }
  }

  /// Handle add item event
  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    // Show loading only if we're in a loaded state
    if (state is CartLoaded) {
      emit(const CartLoading());
    }

    try {
      await _repository.addToCart(event.item);
      final items = await _repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('Failed to add item: $e'));
    }
  }

  /// Handle remove item event
  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      emit(const CartLoading());
    }

    try {
      await _repository.removeFromCart(event.productId);
      final items = await _repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('Failed to remove item: $e'));
    }
  }

  /// Handle quantity update event
  Future<void> _onItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      emit(const CartLoading());
    }

    try {
      await _repository.updateQuantity(event.productId, event.quantity);
      final items = await _repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('Failed to update quantity: $e'));
    }
  }

  /// Handle clear cart event
  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      emit(const CartLoading());
    }

    try {
      await _repository.clearCart();
      emit(const CartLoaded([]));
    } catch (e) {
      emit(CartError('Failed to clear cart: $e'));
    }
  }
}
