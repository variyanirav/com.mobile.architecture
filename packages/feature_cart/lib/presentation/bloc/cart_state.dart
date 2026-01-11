import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

/// Base class for cart states
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state before cart is loaded
class CartInitial extends CartState {
  const CartInitial();
}

/// State when cart is being loaded
class CartLoading extends CartState {
  const CartLoading();
}

/// State when cart is successfully loaded
class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded(this.items);

  @override
  List<Object?> get props => [items];

  // Computed properties
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => items.isEmpty;
}

/// State when cart operation fails
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
