import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

/// Immutable state for Riverpod pattern
class CartState extends Equatable {
  final List<CartItem> items;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    this.items = const <CartItem>[],
    this.isLoading = false,
    this.errorMessage,
  });

  // Computed properties
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => items.isEmpty;

  // CopyWith for immutable updates
  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Clear error
  CartState clearError() {
    return copyWith();
  }

  @override
  List<Object?> get props => [items, isLoading, errorMessage];

  @override
  String toString() =>
      'CartState(items: ${items.length}, loading: $isLoading, error: $errorMessage)';
}
