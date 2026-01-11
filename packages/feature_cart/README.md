# Shopping Cart Feature

This package demonstrates three state management patterns:
- Provider (Simple)
- Riverpod (Modern)
- BLoC (Enterprise)

## Structure

```
lib/
├── domain/
│   ├── entities/
│   │   ├── cart_item.dart
│   │   └── product.dart
│   └── repositories/
│       └── cart_repository.dart
├── data/
│   └── repositories/
│       └── cart_repository_impl.dart
└── presentation/
    ├── provider/
    │   ├── cart_provider.dart
    │   └── cart_page_provider.dart
    ├── riverpod/
    │   ├── cart_state.dart
    │   ├── cart_notifier.dart
    │   ├── cart_providers.dart
    │   └── cart_page_riverpod.dart
    ├── bloc/
    │   ├── cart_event.dart
    │   ├── cart_state.dart
    │   ├── cart_bloc.dart
    │   └── cart_page_bloc.dart
    └── widgets/
        ├── cart_item_tile.dart
        └── product_list.dart
```

## Usage

### Provider Pattern
```dart
ChangeNotifierProvider(
  create: (_) => CartProvider(cartRepository),
  child: CartPageProvider(),
)
```

### Riverpod Pattern
```dart
ProviderScope(
  child: CartPageRiverpod(),
)
```

### BLoC Pattern
```dart
BlocProvider(
  create: (_) => CartBloc(cartRepository),
  child: CartPageBloc(),
)
```
