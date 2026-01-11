import 'package:equatable/equatable.dart';
import 'product.dart';

/// Cart item representing a product in the shopping cart with quantity
class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  /// Total price for this cart item (price * quantity)
  double get totalPrice => product.price * quantity;

  /// Create a copy with modified quantity
  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];

  @override
  String toString() =>
      'CartItem(product: ${product.name}, quantity: $quantity)';
}
