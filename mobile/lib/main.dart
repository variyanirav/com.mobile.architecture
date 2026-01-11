import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feature_cart/feature_cart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for cart persistence
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(child: MyApp(sharedPreferences: sharedPreferences)));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    final cartRepository = CartRepositoryImpl(sharedPreferences);

    return provider_pkg.MultiProvider(
      providers: [
        provider_pkg.Provider<CartRepository>.value(value: cartRepository),
        provider_pkg.ChangeNotifierProvider(
          create: (_) => CartProvider(cartRepository),
        ),
      ],
      child: MaterialApp(
        title: 'State Management Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const StateManagementHomePage(),
      ),
    );
  }
}

class StateManagementHomePage extends StatelessWidget {
  const StateManagementHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Patterns'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a State Management Pattern:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Provider Card
            _PatternCard(
              title: 'Provider',
              description: 'ChangeNotifier pattern with notifyListeners()',
              color: Colors.blue,
              icon: Icons.format_list_bulleted,
              features: const [
                '✓ Simple and intuitive',
                '✓ Built-in to Flutter ecosystem',
                '✓ ChangeNotifier pattern',
              ],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPageProvider()),
              ),
            ),

            const SizedBox(height: 16),

            // Riverpod Card
            _PatternCard(
              title: 'Riverpod',
              description: 'Immutable state with compile-time safety',
              color: Colors.green,
              icon: Icons.security,
              features: const [
                '✓ Compile-time safety',
                '✓ Immutable state updates',
                '✓ Better testability',
              ],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPageRiverpod()),
              ),
            ),

            const SizedBox(height: 16),

            // BLoC Card
            _PatternCard(
              title: 'BLoC',
              description: 'Event-driven architecture with streams',
              color: Colors.purple,
              icon: Icons.architecture,
              features: const [
                '✓ Event-driven design',
                '✓ Predictable state changes',
                '✓ Great for complex logic',
              ],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => provider_pkg.Provider<CartRepository>.value(
                    value: context.read<CartRepository>(),
                    child: const CartPageBloc(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Shopping Cart Demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Each pattern implements the same shopping cart feature '
                      'with shared domain and data layers. Compare the '
                      'different approaches to state management!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final List<String> features;
  final VoidCallback onTap;

  const _PatternCard({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ...features.map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
