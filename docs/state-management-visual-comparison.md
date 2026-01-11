# State Management Visual Comparison

Quick visual reference for the three patterns implemented in `feature_cart`.

---

## 📱 UI Flow

```
┌─────────────────────────────────────────┐
│    State Management Demo (Home)         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 📋 Provider                     │   │
│  │ ChangeNotifier pattern          │   │
│  │ ✓ Simple and intuitive         │   │
│  │ ✓ Built-in to Flutter          │   │
│  │ ✓ ChangeNotifier pattern       │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🔒 Riverpod                     │   │
│  │ Immutable state                 │   │
│  │ ✓ Compile-time safety          │   │
│  │ ✓ Immutable state updates      │   │
│  │ ✓ Better testability           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🏗️  BLoC                        │   │
│  │ Event-driven architecture       │   │
│  │ ✓ Event-driven design          │   │
│  │ ✓ Predictable state changes    │   │
│  │ ✓ Great for complex logic      │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ℹ️  Shopping Cart Demo                │
│  Each pattern implements the same      │
│  cart with shared domain/data layers   │
└─────────────────────────────────────────┘
```

---

## 🔵 Provider Pattern

### Architecture Flow
```
┌──────────────┐
│ CartPageProvider │  ← UI Widget
└────────┬─────┘
         │ Consumer<CartProvider>
         ↓
┌──────────────┐
│ CartProvider │  ← ChangeNotifier
│              │
│ - items      │  ← Mutable State
│ - loading    │
│ - error      │
└────────┬─────┘
         │ calls methods
         ↓
┌──────────────┐
│CartRepository│  ← Data Layer
│     Impl     │
└────────┬─────┘
         │
         ↓
┌──────────────┐
│SharedPreferences│ ← Persistence
└──────────────┘
```

### Code Pattern
```dart
// State Management (Mutable)
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  
  void addToCart(CartItem item) {
    _items.add(item);           // Direct mutation
    notifyListeners();          // Manual notification
  }
}

// UI
Consumer<CartProvider>(
  builder: (context, cart, child) {
    return Text('Items: ${cart.items.length}');
  },
)

// Actions
context.read<CartProvider>().addToCart(item);
```

### Key Characteristics
- **State**: Mutable with manual notifications
- **Rebuilds**: All consumers rebuild (can optimize with Selector)
- **Dependencies**: Requires BuildContext
- **Boilerplate**: Low (89 lines for provider)
- **Theme**: Blue UI

---

## 🟢 Riverpod Pattern

### Architecture Flow
```
┌──────────────┐
│CartPageRiverpod│ ← ConsumerWidget
└────────┬─────┘
         │ ref.watch(cartProvider)
         ↓
┌──────────────┐
│ CartNotifier │  ← StateNotifier<CartState>
│              │
│ state        │  ← Immutable State
└────────┬─────┘
         │ state = state.copyWith(...)
         ↓
┌──────────────┐
│  CartState   │  ← Immutable Data Class
│              │
│ - items      │
│ - isLoading  │
│ - error      │
└────────┬─────┘
         │
         ↓
┌──────────────┐
│CartRepository│  ← Data Layer
│     Impl     │
└────────┬─────┘
         │
         ↓
┌──────────────┐
│SharedPreferences│ ← Persistence
└──────────────┘
```

### Derived Providers
```
cartProvider
    │
    ├─→ itemCountProvider    (computes count)
    ├─→ totalPriceProvider   (computes total)
    └─→ isEmptyProvider      (computes isEmpty)
         
         ↓ Granular rebuilds
         
Only affected widgets rebuild!
```

### Code Pattern
```dart
// Immutable State
@freezed
class CartState with _$CartState {
  factory CartState({
    @Default([]) List<CartItem> items,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _CartState;
  
  // Computed properties
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

// State Management (Immutable)
class CartNotifier extends StateNotifier<CartState> {
  void addToCart(CartItem item) {
    state = state.copyWith(          // Immutable update
      items: [...state.items, item],
    );
    // No notifyListeners - automatic!
  }
}

// Providers
final cartProvider = StateNotifierProvider<CartNotifier, CartState>(...);
final itemCountProvider = Provider((ref) => ref.watch(cartProvider).itemCount);

// UI
final itemCount = ref.watch(itemCountProvider);  // Granular rebuild
ref.read(cartProvider.notifier).addToCart(item); // Action
```

### Key Characteristics
- **State**: Immutable with copyWith
- **Rebuilds**: Granular via derived providers
- **Dependencies**: No BuildContext required
- **Boilerplate**: Medium (95 lines notifier + providers)
- **Theme**: Green UI

---

## 🟣 BLoC Pattern

### Architecture Flow
```
┌──────────────┐
│ CartPageBloc │  ← StatelessWidget
└────────┬─────┘
         │ BlocBuilder<CartBloc, CartState>
         │ context.read<CartBloc>().add(event)
         ↓
┌──────────────┐
│  CartBloc    │  ← Bloc<CartEvent, CartState>
│              │
│ on<Event>()  │  ← Event Handlers
└────────┬─────┘
         │ Event → Handler → Emit State
         ↓
    EVENTS                    STATES
┌──────────────┐         ┌──────────────┐
│CartLoadRequested│      │  CartInitial │
│CartItemAdded │   →    │  CartLoading │
│CartItemRemoved│        │  CartLoaded  │
│CartQuantityUpdated│    │  CartError   │
│CartCleared   │         └──────────────┘
└────────┬─────┘
         │ calls repository
         ↓
┌──────────────┐
│CartRepository│  ← Data Layer
└────────┬─────┘
         │
         ↓
┌──────────────┐
│SharedPreferences│ ← Persistence
└──────────────┘
```

### Event-State Flow
```
UI Action → Event → BLoC Handler → Repository → Emit State → UI Rebuild
   │          │          │              │           │          │
   tap      .add()    on<Event>    async call    emit()   BlocBuilder
```

### Code Pattern
```dart
// Events (Inputs)
abstract class CartEvent extends Equatable {}
class CartItemAdded extends CartEvent {
  final CartItem item;
}

// States (Outputs)
abstract class CartState extends Equatable {}
class CartInitial extends CartState {}
class CartLoading extends CartState {}
class CartLoaded extends CartState {
  final List<CartItem> items;
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
}
class CartError extends CartState {
  final String message;
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._repository) : super(CartInitial()) {
    on<CartItemAdded>(_onItemAdded);
  }
  
  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      await _repository.addToCart(event.item);
      final items = await _repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('Failed: $e'));
    }
  }
}

// UI
BlocBuilder<CartBloc, CartState>(
  builder: (context, state) {
    if (state is CartLoading) return CircularProgressIndicator();
    if (state is CartLoaded) return Text('Items: ${state.itemCount}');
    if (state is CartError) return Text(state.message);
    return SizedBox();
  },
)

// BlocListener for side effects
BlocListener<CartBloc, CartState>(
  listener: (context, state) {
    if (state is CartError) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  child: ...,
)

// Actions
context.read<CartBloc>().add(CartItemAdded(item));
```

### Key Characteristics
- **State**: Explicit sealed states (Initial/Loading/Loaded/Error)
- **Rebuilds**: Controlled via BlocBuilder (buildWhen)
- **Dependencies**: Event-driven, testable with blocTest
- **Boilerplate**: High (events + states + bloc + UI)
- **Theme**: Purple UI

---

## 📊 Side-by-Side Comparison

### Adding an Item

| Aspect | Provider | Riverpod | BLoC |
|--------|----------|----------|------|
| **Trigger** | `provider.addToCart(item)` | `notifier.addToCart(item)` | `bloc.add(CartItemAdded(item))` |
| **State Update** | Direct mutation | Immutable copy | Event → State emission |
| **Notification** | `notifyListeners()` | Automatic | `emit(CartLoaded(...))` |
| **UI Rebuild** | All Consumers | Only watchers | BlocBuilder |

### Displaying Cart Count

| Pattern | Code | Rebuilds |
|---------|------|----------|
| **Provider** | `Consumer<CartProvider>(builder: (_, cart, __) => Text('${cart.items.length}'))` | Full Consumer |
| **Riverpod** | `ref.watch(itemCountProvider)` | Only this widget |
| **BLoC** | `BlocBuilder<CartBloc, CartState>(builder: (_, state) => Text('${state.itemCount}'))` | BlocBuilder only |

### Error Handling

```dart
// Provider
try {
  await _repository.addToCart(item);
  notifyListeners();
} catch (e) {
  _error = e.toString();
  notifyListeners();
}

// Riverpod
try {
  await _repository.addToCart(item);
  state = state.copyWith(items: newItems);
} catch (e) {
  state = state.copyWith(errorMessage: e.toString());
}

// BLoC
try {
  await _repository.addToCart(item);
  emit(CartLoaded(newItems));
} catch (e) {
  emit(CartError(e.toString()));
}
```

---

## 🎯 Decision Matrix

> **⚠️ CRITICAL NOTE:**  
> This simplified matrix is **NOT sufficient** for production decisions!  
> It focuses on subjective criteria (simplicity, team familiarity).  
>  
> **For objective, evidence-based criteria, see:**  
> [State Management Decision Framework](./state-management-decision-framework.md)  
>  
> **Real factors that matter more than team size:**  
> - Application performance requirements (FPS, rebuild efficiency)  
> - Business logic complexity (state machines, workflows)  
> - Daily active users (DAU scale)  
> - Compliance and audit requirements  
> - Testing coverage requirements  
> - Project lifespan (months vs years)

### Choose Provider if:
- ✅ Building simple app (< 10 screens, < 1K DAU)
- ✅ Team familiar with ChangeNotifier
- ✅ Want minimal boilerplate
- ✅ Short project lifespan (< 6 months)
- ✅ Performance not critical
- ❌ Not: Complex state, high DAU, extensive testing, regulated industry

### Choose Riverpod if:
- ✅ Want modern, safe state management
- ✅ Need dependency injection
- ✅ Performance critical (real-time, animations)
- ✅ Prefer immutable state
- ✅ Value compile-time errors over runtime
- ✅ Medium to high DAU (1K - 100K+)
- ✅ Project lifespan 6 months - 3 years
- ❌ Not: Quick MVP with tight deadline

### Choose BLoC if:
- ✅ Building enterprise app in regulated industry
- ✅ Need audit trails (finance, healthcare)
- ✅ Complex business logic and state machines
- ✅ High DAU (10K+)
- ✅ Need extensive testing (TDD with high coverage)
- ✅ Want predictable state flow
- ✅ Long-term project (2+ years)
- ❌ Not: Simple CRUD, MVP, tight deadline

---

## 📈 Metrics from Implementation

| Metric | Provider | Riverpod | BLoC |
|--------|----------|----------|------|
| **Lines of Code** | 220 | 230 | 280 |
| **Files** | 2 | 4 | 4 |
| **Setup Time** | 5 min | 10 min | 15 min |
| **Boilerplate** | Low | Medium | High |
| **Type Safety** | Runtime | Compile-time | Compile-time |
| **Testability** | Good | Excellent | Excellent |
| **Learning Curve** | Easy | Medium | Hard |
| **Rebuild Control** | Manual (Selector) | Automatic (derived) | Explicit (buildWhen) |
| **Dependencies** | provider ^6.1.1 | flutter_riverpod ^2.5.1 | flutter_bloc ^9.1.1 |

---

## 🔍 What to Look For During Testing

### Provider
- **Watch**: How many widgets rebuild when cart changes?
- **Check**: Does BuildContext cause issues?
- **Notice**: Simple, intuitive code

### Riverpod
- **Watch**: Only affected providers trigger rebuilds
- **Check**: Autocomplete and type safety
- **Notice**: No BuildContext needed, clean dependency injection

### BLoC
- **Watch**: Clear event → state flow in debug logs
- **Check**: BlocListener for side effects (snackbars)
- **Notice**: Predictable, testable, but verbose

---

## 🏆 Real-World Usage

### Provider
**Use Cases:**
- Personal productivity apps (to-do, notes)
- Internal company tools
- MVPs and prototypes
- Learning projects
- Simple content apps

**Real Examples:**
- Small business apps
- Portfolio apps
- Simple dashboards

---

### Riverpod
**Use Cases:**
- E-commerce applications
- Social media apps
- Content platforms (Medium-like)
- SaaS products
- News aggregators

**Real Examples:**
- **Invoiceninja** (invoicing platform)
- Modern Flutter apps with complex state
- Apps requiring high test coverage

---

### BLoC
**Use Cases:**
- Banking and fintech apps
- Healthcare applications
- Insurance platforms
- Trading platforms
- Enterprise resource planning (ERP)
- Apps requiring audit trails

**Real Examples:**
- **Alibaba** (e-commerce, millions of users)
- **BMW** (car connectivity app)
- **Hamilton Musical** (ticketing)
- Fortune 500 internal apps
- Regulated industry applications

---

**Technical Reality Check:**

| App Type | DAU | Complexity | Recommended | Why |
|----------|-----|------------|-------------|-----|
| **Personal Tracker** | < 100 | Low | Provider | Simple, no scale needed |
| **Small Business CRM** | < 1K | Medium | Provider or Riverpod | Depends on feature complexity |
| **E-commerce Store** | 10K+ | High | Riverpod | Performance + testability |
| **Banking App** | 100K+ | Very High | BLoC | Compliance + audit trails |
| **Social Media** | 1M+ | Very High | BLoC or Riverpod | Scale + performance critical |

**Key Insight:** DAU and complexity matter more than team size!

---

**Remember**: All three patterns share the same domain and data layers!  
The only difference is the presentation layer. 🎨

Test them all and choose what fits YOUR project best! 🚀
