import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// Cart page using BLoC pattern
class CartPageBloc extends StatelessWidget {
  const CartPageBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(context.read<CartRepository>()),
      child: const _CartPageContent(),
    );
  }
}

class _CartPageContent extends StatelessWidget {
  const _CartPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart (BLoC)'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          // Cart badge
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final itemCount = state is CartLoaded ? state.itemCount : 0;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Badge(
                    label: Text('$itemCount'),
                    isLabelVisible: itemCount > 0,
                    child: const Icon(Icons.shopping_cart),
                  ),
                ),
              );
            },
          ),
          // Clear cart button
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final hasItems = state is CartLoaded && state.items.isNotEmpty;
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: hasItems
                    ? () => _showClearConfirmation(context)
                    : null,
              );
            },
          ),
        ],
      ),
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          // Show error snackbar
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartInitial) {
              return const Center(child: Text('Initializing cart...'));
            }

            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<CartBloc>().add(
                        const CartLoadRequested(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is CartLoaded) {
              if (state.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _CartItemTile(item: item);
                      },
                    ),
                  ),
                  _CartSummary(state: state),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(const CartCleared());
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final demoProducts = [
      const Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'Latest Apple smartphone with A17 Pro chip',
        price: 999.99,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      const Product(
        id: '2',
        name: 'MacBook Pro',
        description: 'Powerful laptop with M3 chip',
        price: 2499.99,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      const Product(
        id: '3',
        name: 'AirPods Pro',
        description: 'Active noise cancellation earbuds',
        price: 249.99,
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Product'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: demoProducts.length,
            itemBuilder: (context, index) {
              final product = demoProducts[index];
              return ListTile(
                leading: CircleAvatar(child: Text(product.name[0])),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                onTap: () {
                  context.read<CartBloc>().add(
                    CartItemAdded(CartItem(product: product, quantity: 1)),
                  );
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(item.product.name[0])),
        title: Text(item.product.name),
        subtitle: Text(
          '\$${item.product.price.toStringAsFixed(2)} × ${item.quantity}\n'
          'Total: \$${item.totalPrice.toStringAsFixed(2)}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: item.quantity > 1
                  ? () {
                      context.read<CartBloc>().add(
                        CartItemQuantityUpdated(
                          item.product.id,
                          item.quantity - 1,
                        ),
                      );
                    }
                  : null,
            ),
            Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                context.read<CartBloc>().add(
                  CartItemQuantityUpdated(item.product.id, item.quantity + 1),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<CartBloc>().add(CartItemRemoved(item.product.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartLoaded state;

  const _CartSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items:', style: TextStyle(fontSize: 16)),
              Text('${state.itemCount}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${state.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checkout feature not implemented yet'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Checkout', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
