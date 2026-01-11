import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import 'cart_providers.dart';

/// Shopping cart page using Riverpod pattern
class CartPageRiverpod extends ConsumerWidget {
  const CartPageRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the entire cart state
    final cartState = ref.watch(cartProvider);

    // Watch specific derived values (granular rebuilds)
    final itemCount = ref.watch(cartItemCountProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart (Riverpod)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Cart badge - only rebuilds when itemCount changes
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Badge(
                label: Text('$itemCount'),
                child: const Icon(Icons.shopping_cart),
              ),
            ),
          ),
        ],
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartState.errorMessage != null
          ? _buildError(context, ref, cartState.errorMessage!)
          : cartState.isEmpty
          ? _buildEmpty()
          : _buildCartList(context, ref, cartState, totalPrice),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context, ref),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(cartProvider.notifier).loadCart(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    WidgetRef ref,
    cartState,
    double totalPrice,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartState.items.length,
            itemBuilder: (context, index) {
              final item = cartState.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(item.product.imageUrl),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text(
                    '\$${item.product.price.toStringAsFixed(2)} × ${item.quantity}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .removeItem(item.product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          ref.read(cartProvider.notifier).clearCart(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Clear Cart'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Checkout not implemented'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final products = [
      const Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'Latest Apple smartphone',
        price: 999.99,
        imageUrl: 'https://picsum.photos/200?random=1',
      ),
      const Product(
        id: '2',
        name: 'MacBook Pro',
        description: 'Powerful laptop',
        price: 2499.99,
        imageUrl: 'https://picsum.photos/200?random=2',
      ),
      const Product(
        id: '3',
        name: 'AirPods Pro',
        description: 'Wireless earbuds',
        price: 249.99,
        imageUrl: 'https://picsum.photos/200?random=3',
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: products
              .map(
                (product) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.imageUrl),
                  ),
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  onTap: () {
                    ref
                        .read(cartProvider.notifier)
                        .addItem(CartItem(product: product, quantity: 1));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} added to cart')),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
