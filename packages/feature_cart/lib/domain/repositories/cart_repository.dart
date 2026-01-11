import '../entities/cart_item.dart';

/// Repository interface for cart operations
/// This defines the contract that all implementations must follow
abstract class CartRepository {
  /// Get all items currently in the cart
  Future<List<CartItem>> getCartItems();

  /// Add a product to the cart (increases quantity if already exists)
  Future<void> addToCart(CartItem item);

  /// Remove a product from the cart completely
  Future<void> removeFromCart(String productId);

  /// Update the quantity of a product in the cart
  Future<void> updateQuantity(String productId, int quantity);

  /// Clear all items from the cart
  Future<void> clearCart();

  /// Get the total number of items in the cart
  Future<int> getItemCount();

  /// Get the total price of all items in the cart
  Future<double> getTotalPrice();
}
