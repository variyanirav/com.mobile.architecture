# Package Architecture Patterns - Visual Guide

## Pattern 1: Tightly Coupled (❌ Wrong)

```
┌─────────────────┐
│  feature_feed   │
│                 │
│  imports        │
│      ↓          │
│  feature_auth   │ ← Direct dependency!
└─────────────────┘
```

**Problem:** If you remove `feature_auth`, `feature_feed` breaks!

---

## Pattern 2: Loosely Coupled via Domain (✅ Correct)

```
┌─────────────────┐         ┌─────────────────┐
│  feature_feed   │         │  feature_auth   │
│                 │         │                 │
│  implements     │         │  implements     │
│      ↓          │         │      ↓          │
│  SessionConsumer│         │  SessionProvider│
└────────┬────────┘         └────────┬────────┘
         │                           │
         │        ┌─────────┐        │
         └───────→│ domain  │←───────┘
                  │         │
                  │ defines │
                  │interface│
                  └─────────┘
```

**Benefits:** 
- Features don't know about each other
- Both depend on stable contracts (domain)
- Can swap implementations
- Easy to test with mocks

---

## Pattern 3: Monolithic vs Modular

### Before (Monolithic)
```
mobile/
  └── lib/
      ├── core/
      │   └── error/
      └── features/
          ├── auth/
          ├── feed/
          └── payment/
```

**Problems:**
- No enforced boundaries
- Hard to test in isolation
- Slow rebuilds
- Merge conflicts

### After (Modular)
```
packages/
  ├── domain/          ← Shared contracts
  ├── core/            ← Infrastructure
  ├── feature_auth/    ← Auth feature
  ├── feature_feed/    ← Feed feature
  └── feature_payment/ ← Payment feature

mobile/
  └── lib/
      └── main.dart    ← Just imports packages
```

**Benefits:**
- Enforced boundaries (compiler checks)
- Independent testing
- Fast incremental builds
- Clear ownership

---

## Pattern 4: Entity Composition

### ❌ Wrong: Inheritance
```
domain/
  └── User

payment/
  └── PaymentUser extends User  ← Tight coupling!
```

### ✅ Right: Composition
```
domain/
  └── User (stable base)

payment/
  └── PaymentProfile
      ├── user: User          ← Composes!
      └── paymentMethods: []
```

---

## Pattern 5: Separating Domain from UI

### Single Package with Multiple UIs
```
feature_auth_domain/          ← Business logic
  └── usecases/
      ├── login_with_email
      ├── login_with_otp
      └── login_with_social

feature_auth_ui_basic/        ← Simple UI
  └── email_login_page

feature_auth_ui_advanced/     ← Complex UI
  ├── email_login_page
  ├── otp_login_page
  └── social_login_page

feature_auth_ui_custom/       ← Your custom design
  └── custom_login_page
```

**App A uses:** `auth_domain` + `auth_ui_basic`  
**App B uses:** `auth_domain` + `auth_ui_advanced`  
**App C uses:** `auth_domain` + `auth_ui_custom`

---

## Pattern 6: Micro Packages (Granular)

```
auth_core/                    ← Essential (always needed)
  ├── session_manager
  └── logout

auth_email/                   ← Optional
  └── email_login

auth_otp/                     ← Optional
  └── otp_login

auth_social/                  ← Optional
  └── social_login

auth_biometric/               ← Optional
  └── biometric_login
```

**App dependencies:**
```yaml
# Simple app
dependencies:
  auth_core: ^1.0.0
  auth_email: ^1.0.0

# Advanced app
dependencies:
  auth_core: ^1.0.0
  auth_email: ^1.0.0
  auth_otp: ^1.0.0
  auth_social: ^1.0.0
  auth_biometric: ^1.0.0
```

**Benefits:** Only import what you need!

---

## Pattern 7: Complete E-Commerce Architecture

```
                    ┌─────────────┐
                    │ mobile app  │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ↓                  ↓                  ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│ feature_auth  │  │ feature_feed  │  │feature_payment│
└───────┬───────┘  └───────┬───────┘  └───────┬───────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                    ┌──────┴──────┐
                    │   domain    │ ← Shared contracts
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │    core     │ ← Infrastructure
                    └─────────────┘
```

**Dependency flow:**
- App → Features
- Features → Domain
- Domain → Core
- **Features ✗ Features** (never!)

---

## Decision Tree: Which Pattern to Use?

```
Start
  │
  ├─→ Simple app (1-2 features)?
  │   └─→ YES → Monolithic with Clean Arch
  │   └─→ NO → Continue
  │
  ├─→ Need to share user/token data?
  │   └─→ YES → Domain package with interfaces
  │
  ├─→ Multiple apps with different UIs?
  │   └─→ YES → Separate domain from UI
  │
  ├─→ Features have optional capabilities?
  │   └─→ YES → Micro packages
  │
  └─→ Complex enterprise app (5+ features)?
      └─→ YES → Full modular architecture
```

---

## Testing Architecture

```
┌─────────────────────────────────────┐
│        feature_feed (testing)       │
│                                     │
│  FeedRepository                     │
│      ↓                              │
│  SessionProvider interface          │
│      ↓                              │
│  MockSessionProvider ← Test double! │
└─────────────────────────────────────┘

No dependency on real feature_auth!
```

---

## Summary: Coupling Matrix

| Pattern | Coupling Level | Use When | Example |
|---------|---------------|----------|---------|
| Direct import | ❌ Tight | Never | `feature_a → feature_b` |
| Domain interface | ✅ Loose | Always | `feature_a → domain ← feature_b` |
| Composition | ✅ Loose | Extending entities | `PaymentProfile { user: User }` |
| Micro packages | ✅ Loose | Optional features | `auth_email`, `auth_otp` |
| Monolithic | ⚠️ Medium | Simple apps | All in `lib/features/` |

---

## Key Takeaways

1. **Never** have features depend on each other directly
2. **Always** depend on abstractions (domain interfaces)
3. **Separate** business logic from UI for flexibility
4. **Compose** entities, don't inherit across boundaries
5. **Split** large features into micro packages for granularity
6. **Test** with mocks, not real implementations
7. **Start simple**, evolve as complexity grows

Remember: **Loose coupling = Better architecture!**
