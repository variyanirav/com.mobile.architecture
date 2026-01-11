import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';

/// Implementation of CartRepository using SharedPreferences for persistence
class CartRepositoryImpl implements CartRepository {
  static const String _cartKey = 'shopping_cart';
  final SharedPreferences _prefs;

  CartRepositoryImpl(this._prefs);

  @override
  Future<List<CartItem>> getCartItems() async {
    try {
      final jsonString = _prefs.getString(_cartKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => _cartItemFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addToCart(CartItem item) async {
    final items = await getCartItems();

    // Check if product already exists
    final existingIndex = items.indexWhere(
      (i) => i.product.id == item.product.id,
    );

    if (existingIndex >= 0) {
      // Update quantity
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      items.add(item);
    }

    await _saveCart(items);
  }

  @override
  Future<void> removeFromCart(String productId) async {
    final items = await getCartItems();
    items.removeWhere((item) => item.product.id == productId);
    await _saveCart(items);
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
      await _saveCart(items);
    }
  }

  @override
  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
  }

  @override
  Future<int> getItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  @override
  Future<double> getTotalPrice() async {
    final items = await getCartItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Private helper methods
  Future<void> _saveCart(List<CartItem> items) async {
    final jsonList = items.map((item) => _cartItemToJson(item)).toList();
    await _prefs.setString(_cartKey, json.encode(jsonList));
  }

  Map<String, dynamic> _cartItemToJson(CartItem item) {
    return {
      'product': {
        'id': item.product.id,
        'name': item.product.name,
        'description': item.product.description,
        'price': item.product.price,
        'imageUrl': item.product.imageUrl,
      },
      'quantity': item.quantity,
    };
  }

  CartItem _cartItemFromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>;
    return CartItem(
      product: Product(
        id: productJson['id'] as String,
        name: productJson['name'] as String,
        description: productJson['description'] as String,
        price: (productJson['price'] as num).toDouble(),
        imageUrl: productJson['imageUrl'] as String,
      ),
      quantity: json['quantity'] as int,
    );
  }
}
