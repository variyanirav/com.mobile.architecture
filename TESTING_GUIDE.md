# Testing Guide - Day 4 State Management

## Quick Start

### 1. Run the Application
```bash
cd mobile
flutter run
```

### 2. Test Each Pattern

#### On Home Screen:
You'll see three cards:
- **Provider** (Blue) - Simple ChangeNotifier pattern
- **Riverpod** (Green) - Modern compile-safe pattern  
- **BLoC** (Purple) - Event-driven architecture

Tap each card to navigate to the shopping cart implementation.

---

## Testing Checklist

### Provider Pattern (Blue)
- [ ] Add products (iPhone, MacBook, AirPods)
- [ ] Cart badge updates in app bar
- [ ] Increase/decrease quantity with +/- buttons
- [ ] Total price calculates correctly
- [ ] Remove individual items
- [ ] Clear cart (confirmation dialog)
- [ ] Cart persists after app restart
- [ ] Loading indicator shows during operations
- [ ] Error handling (disconnect network, force error)

### Riverpod Pattern (Green)
- [ ] Same tests as Provider
- [ ] Notice: No BuildContext errors
- [ ] Observe: Granular rebuilds (only affected widgets update)
- [ ] Check: Type safety with autocomplete

### BLoC Pattern (Purple)
- [ ] Same tests as Provider
- [ ] Notice: Event-driven flow (add event → state change)
- [ ] Check: BlocListener shows snackbars
- [ ] Observe: State transitions (Loading → Loaded → Error)

---

## Performance Testing

### 1. Enable Performance Overlay
```dart
// In main.dart, set:
showPerformanceOverlay: true,
```

### 2. Use Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Open in browser and profile:
- **Timeline**: Check rebuild frequency
- **Memory**: Monitor state object allocation
- **Performance**: Compare FPS across patterns

### 3. Rebuild Tracking

Add this to each pattern's widget:
```dart
@override
Widget build(BuildContext context) {
  print('${runtimeType} rebuilt');  // Track rebuilds
  return ...;
}
```

**Expected Results**:
- Provider: More rebuilds (entire Consumer rebuilds)
- Riverpod: Fewer rebuilds (only watchers of changed providers)
- BLoC: Controlled rebuilds (BlocBuilder with buildWhen)

---

## Debugging Tips

### Provider Debug
```dart
// In CartProvider
@override
void notifyListeners() {
  print('CartProvider notified: $_items');
  super.notifyListeners();
}
```

### Riverpod Debug
```dart
// In pubspec.yaml dev_dependencies:
flutter_riverpod: ^2.5.1

// In main.dart:
ProviderScope(
  observers: [ProviderLogger()],  // Log all provider changes
  child: MyApp(),
);

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('Provider updated: ${provider.name ?? provider.runtimeType}');
    print('  Previous: $previousValue');
    print('  New: $newValue');
  }
}
```

### BLoC Debug
```dart
// In main.dart:
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(MyApp());
}

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('Event: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('Transition: ${transition.currentState} → ${transition.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('Error: $error');
  }
}
```

---

## Common Issues & Solutions

### Issue: "Package not found"
```bash
# Solution: Run melos bootstrap
~/.pub-cache/bin/melos bootstrap
```

### Issue: Version conflict
```
Because feature_cart depends on flutter_bloc ^8.1.5 and 
feature_auth depends on flutter_bloc ^9.1.1, version solving failed.
```
**Solution**: Align all packages to same version (^9.1.1)

### Issue: SharedPreferences not persisting
```dart
// Check if initialized
final prefs = await SharedPreferences.getInstance();
print('Cart data: ${prefs.getString('shopping_cart')}');
```

### Issue: State not updating
- **Provider**: Check `notifyListeners()` is called
- **Riverpod**: Check using `state = ` not `state.field = `
- **BLoC**: Check event is added via `add()`, not direct call

### Issue: Hot reload not working
```bash
# Stop app and restart
flutter run
```

---

## Manual Testing Script

### Scenario 1: Basic Flow
1. Launch app
2. Tap "Provider" card
3. Tap "Add Product" button
4. Select "iPhone 15 Pro"
5. Verify cart badge shows "1"
6. Verify total shows "$999.99"
7. Tap "+" button
8. Verify quantity = 2, total = "$1,999.98"
9. Close app completely
10. Reopen app, navigate to Provider cart
11. Verify cart still has 2 iPhones ✅

### Scenario 2: Multi-Pattern Persistence
1. In Provider cart: Add 2 MacBooks
2. Go back to home
3. Navigate to Riverpod cart
4. Verify 2 MacBooks appear ✅ (same storage)
5. Add 1 AirPods in Riverpod
6. Go back, navigate to BLoC cart
7. Verify all items appear ✅

### Scenario 3: Error Handling
1. Navigate to any cart
2. Turn off device network
3. Try adding product
4. Should gracefully handle (or succeed if local only)
5. Turn on network
6. Verify app continues working ✅

---

## Unit Testing

### Run Tests
```bash
# Test specific package
cd packages/feature_cart
flutter test

# Test all packages
~/.pub-cache/bin/melos run test
```

### Example Tests (To Implement)

#### Provider Test
```dart
// test/provider/cart_provider_test.dart
void main() {
  test('adds item to cart', () async {
    final repository = MockCartRepository();
    final provider = CartProvider(repository);
    
    final product = Product(id: '1', name: 'Test', price: 99.99);
    await provider.addToCart(CartItem(product: product, quantity: 1));
    
    expect(provider.items.length, 1);
    expect(provider.totalPrice, 99.99);
  });
}
```

#### Riverpod Test
```dart
// test/riverpod/cart_notifier_test.dart
void main() {
  test('adds item immutably', () async {
    final container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(MockCartRepository()),
      ],
    );
    
    final notifier = container.read(cartProvider.notifier);
    await notifier.addToCart(testItem);
    
    final state = container.read(cartProvider);
    expect(state.items.length, 1);
  });
}
```

#### BLoC Test
```dart
// test/bloc/cart_bloc_test.dart
void main() {
  blocTest<CartBloc, CartState>(
    'emits [CartLoading, CartLoaded] when item added',
    build: () => CartBloc(MockCartRepository()),
    act: (bloc) => bloc.add(CartItemAdded(testItem)),
    expect: () => [
      CartLoading(),
      CartLoaded([testItem]),
    ],
  );
}
```

---

## Performance Benchmarks

Expected metrics from testing:

| Metric | Provider | Riverpod | BLoC |
|--------|----------|----------|------|
| Rebuilds per operation | ~5-10 | ~2-3 | ~2-4 |
| Memory (avg) | 12MB | 14MB | 16MB |
| Code lines | 220 | 230 | 280 |
| Setup time | 5 min | 10 min | 15 min |
| Learning curve | Easy | Medium | Hard |

---

## Next Steps After Testing

1. **Document Findings**: Note performance, ease of use, bugs
2. **Choose Pattern**: Based on your project needs
3. **Create ADR**: Use `docs/adr/001-state-management-choice.md`
4. **Implement Tests**: Add unit tests for chosen pattern
5. **Refactor**: Apply chosen pattern to rest of app

---

**Happy Testing! 🚀**

Report issues or observations in LEARNING.md
