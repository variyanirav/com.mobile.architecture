import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

/// Base class for cart events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load cart from repository
class CartLoadRequested extends CartEvent {
  const CartLoadRequested();
}

/// Event to add item to cart
class CartItemAdded extends CartEvent {
  final CartItem item;

  const CartItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Event to remove item from cart
class CartItemRemoved extends CartEvent {
  final String productId;

  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to update item quantity
class CartItemQuantityUpdated extends CartEvent {
  final String productId;
  final int quantity;

  const CartItemQuantityUpdated(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

/// Event to clear entire cart
class CartCleared extends CartEvent {
  const CartCleared();
}
