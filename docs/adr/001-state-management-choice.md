# ADR 001: State Management Pattern Choice

**Status:** Proposed  
**Date:** 2026-01-10  
**Decision Makers:** [Your Name]  
**Context:** Day 4 - State Management Patterns Comparison

---

## Context and Problem Statement

We need to choose a state management pattern for our Flutter application. The choice affects:
- Code maintainability and testability
- Development speed and learning curve
- Team scalability and collaboration
- Architecture enforcement

The application will include:
- Multiple features (auth, cart, profile, etc.)
- Complex business logic
- Asynchronous operations (API calls, local storage)
- Need for testing at all levels

---

## Decision Drivers

* **Team Size:** [1-2 developers / 3-5 developers / 5+ developers]
* **App Complexity:** [Simple (5-10 screens) / Medium (10-20 screens) / Complex (20+ screens)]
* **Testing Requirements:** [Basic / Medium / Comprehensive]
* **Time to Market:** [MVP in weeks / Production in months / Long-term project]
* **Team Flutter Experience:** [Beginner / Intermediate / Advanced]

---

## Considered Options

### Option 1: Provider
**Pros:**
- ✅ Official Flutter recommendation
- ✅ Simple and easy to learn
- ✅ Low boilerplate
- ✅ Good community support
- ✅ Works well with DevTools

**Cons:**
- ❌ Requires `BuildContext` (tight coupling)
- ❌ Easy to cause unnecessary rebuilds
- ❌ No compile-time dependency safety
- ❌ Harder to test (needs widgets)

**Code Example:**
```dart
// Provider
context.read<CartProvider>().addItem(item);

// Testing requires setup
final provider = CartProvider();
await provider.addItem(item);
expect(provider.items.length, 1);
```

---

### Option 2: Riverpod
**Pros:**
- ✅ No `BuildContext` needed (better testability)
- ✅ Compile-time safety
- ✅ Better dependency injection
- ✅ Automatic disposal
- ✅ Granular rebuilds with derived providers
- ✅ Modern best practices

**Cons:**
- ❌ Learning curve (new concepts)
- ❌ More setup initially
- ❌ Smaller community than Provider
- ❌ Less third-party examples

**Code Example:**
```dart
// Riverpod
ref.read(cartProvider.notifier).addItem(item);

// Testing is clean
final container = ProviderContainer();
await container.read(cartProvider.notifier).addItem(item);
expect(container.read(cartProvider).items.length, 1);
```

---

### Option 3: BLoC (Business Logic Component)
**Pros:**
- ✅ Very testable (stream-based)
- ✅ Clear separation (events/states)
- ✅ Excellent DevTools support
- ✅ Predictable state transitions
- ✅ Great for complex flows
- ✅ Strong architectural patterns

**Cons:**
- ❌ High boilerplate (events, states, bloc)
- ❌ Steep learning curve
- ❌ Overkill for simple features
- ❌ Requires discipline and consistency

**Code Example:**
```dart
// BLoC
context.read<CartBloc>().add(CartItemAdded(item));

// Testing with blocTest
blocTest<CartBloc, CartState>(
  'adds item to cart',
  build: () => CartBloc(),
  act: (bloc) => bloc.add(CartItemAdded(item)),
  expect: () => [isA<CartLoaded>()],
);
```

---

## Decision Outcome

**Chosen option:** [CHOOSE ONE: Provider / Riverpod / BLoC]

### Justification

[Fill in your reasoning, example:]

**If choosing Riverpod:**
We chose Riverpod because:
1. Our app has medium complexity (15+ screens)
2. We need strong dependency injection for testability
3. Team is comfortable with modern Flutter patterns
4. No BuildContext dependency makes testing cleaner
5. Compile-time safety prevents runtime errors
6. Future-proof choice aligned with Flutter's direction

**If choosing Provider:**
We chose Provider because:
1. Simple app (< 10 screens)
2. Team is learning Flutter
3. Need quick prototyping
4. Large community support
5. Official recommendation

**If choosing BLoC:**
We chose BLoC because:
1. Enterprise app with complex flows
2. Multiple developers (5+)
3. Need strict architectural patterns
4. Testing is critical requirement
5. Audit trails needed (event logs)

---

## Consequences

### Positive
- [List expected benefits]
- Example: Clean separation of business logic from UI
- Example: Easy to test without UI dependencies
- Example: Type-safe state management

### Negative
- [List challenges or tradeoffs]
- Example: Initial learning curve for team
- Example: More setup required per feature
- Example: Need to establish patterns and conventions

### Neutral
- [Other impacts]
- Example: Need to document patterns for team
- Example: Will need training session for new developers

---

## Implementation Plan

1. **Week 1:**
   - Set up chosen pattern in auth feature
   - Create example/template for team
   - Document patterns in repository

2. **Week 2:**
   - Migrate/implement cart feature
   - Write tests for both features
   - Team code review to establish standards

3. **Ongoing:**
   - All new features use this pattern
   - No mixing of state management patterns
   - Update this ADR if issues arise

---

## Validation

How we'll know if this decision was correct:
- [ ] Tests are easy to write (< 5 min per feature)
- [ ] New developers can understand code within 1 week
- [ ] No state-related bugs in production
- [ ] Code reviews are faster (clear patterns)
- [ ] Team satisfaction score > 7/10

**Review Date:** [3 months from now]

---

## References

- [Provider Documentation](https://pub.dev/packages/provider)
- [Riverpod Documentation](https://riverpod.dev/)
- [BLoC Documentation](https://bloclibrary.dev/)
- [Day 4 State Management Guide](../../DAY_4.md)
- [Flutter State Management Options](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)

---

## Notes

[Add any additional context, team discussion notes, or considerations]

Example:
- Considered GetX but rejected due to "magic" nature and testing difficulties
- May revisit this decision in 6 months based on team growth
- BLoC considered overkill for current team size (2 developers)
