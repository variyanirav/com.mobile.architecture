**Day 2: Clean Architecture for Flutter**

---
## 🎯 Goal

Understand **Clean Architecture** and how to map it into a **Flutter app structure** — so that your apps are:

* Scalable (easy to add features),
* Testable (logic independent of UI),
* Maintainable (clear separation of layers).

**Time allocation (60 minutes):**
- 15m: Read Clean Architecture summary and core concepts
- 25m: Sketch Flutter app mapping to Clean Arch layers (paper/whiteboard)
- 15m: Create C4 Context diagram
- 5m: Set up analysis_options.yaml with flutter_lints

---

## 🧠 Step 1: Learn the Core Concept

### 📘 The Core Idea (Uncle Bob’s Clean Architecture)

Every software system can be layered like an onion:

```
          +-----------------------------+
          |        Presentation         | ← UI (Widgets)
          +-----------------------------+
          |         Application         | ← Use cases (business rules)
          +-----------------------------+
          |          Domain             | ← Entities (core models)
          +-----------------------------+
          |       Infrastructure        | ← External systems: APIs, DB
          +-----------------------------+
```

* **Entities (Domain):**

  * The heart of the app — pure business rules, independent of frameworks.
  * Example: `User`, `Task`, `Project` models + validation logic.

* **Use Cases (Application):**

  * Contain the business workflows — coordinate entities and repositories.
  * Example: `LoginUser`, `FetchUserTasks`, `AddTask`.

* **Interface Adapters (Data):**

  * Translate data from external systems (API/DB) into entities and vice versa.
  * Example: `UserRepositoryImpl` converts `UserDTO` ↔ `User`.

* **Frameworks & UI (Presentation):**

  * Flutter widgets, state management, and actual rendering.
  * Example: `LoginPage`, `TaskListPage`, using BLoC / Riverpod for state.

**Dependency Rule:**
👉 Inner layers never depend on outer layers.
Use **abstractions (interfaces)** for communication inward-outward.

---

## 🏗 Step 2: Apply to Flutter

Here’s how you map those layers in Flutter folder structure:

```
lib/
 ├── core/
 │   ├── error/
 │   ├── usecases/
 │   └── utils/
 │
 ├── features/
 │   ├── auth/
 │   │   ├── domain/
 │   │   │   ├── entities/
 │   │   │   │   └── user_entity.dart
 │   │   │   │
 │   │   │   ├── repositories/
 │   │   │   │   └── auth_repository.dart
 │   │   │   │
 │   │   │   └── usecases/
 │   │   │       ├── login_usecase.dart
 │   │   │       ├── register_usecase.dart
 │   │   │       ├── forgot_password_usecase.dart
 │   │   │       ├── send_otp_usecase.dart
 │   │   │       ├── verify_otp_usecase.dart
 │   │   │       └── logout_usecase.dart
 │   │   │
 │   │   ├── data/
 │   │   │   ├── models/
 │   │   │   │   ├── user_model.dart
 │   │   │   │   ├── login_request_model.dart
 │   │   │   │   ├── register_request_model.dart
 │   │   │   │   ├── forgot_password_request_model.dart
 │   │   │   │   └── auth_response_model.dart
 │   │   │   │
 │   │   │   └── repositories_impl/
 │   │   │       └── auth_repository_impl.dart
 │   │   │
 │   │   └── presentation/
 │   │       ├── login/
 │   │       │   ├── bloc/
 │   │       │   │   ├── login_bloc.dart
 │   │       │   │   ├── login_event.dart
 │   │       │   │   └── login_state.dart
 │   │       │   │
 │   │       │   └── pages/
 │   │       │       └── login_page.dart
 │   │       │
 │   │       ├── register/
 │   │       │   ├── bloc/
 │   │       │   │   ├── register_bloc.dart
 │   │       │   │   ├── register_event.dart
 │   │       │   │   └── register_state.dart
 │   │       │   │
 │   │       │   └── pages/
 │   │       │       └── register_page.dart
 │   │       │
 │   │       ├── forgot_password/
 │   │       │   ├── bloc/
 │   │       │   │   ├── forgot_password_bloc.dart
 │   │       │   │   ├── forgot_password_event.dart
 │   │       │   │   └── forgot_password_state.dart
 │   │       │   │
 │   │       │   └── pages/
 │   │       │       └── forgot_password_page.dart
 │   │       │
 │   │       ├── otp/
 │   │       │   ├── bloc/
 │   │       │   │   ├── otp_bloc.dart
 │   │       │   │   ├── otp_event.dart
 │   │       │   │   └── otp_state.dart
 │   │       │   │
 │   │       │   └── pages/
 │   │       │       └── otp_page.dart
 │   │       │
 │   │       └── common/
 │   │           ├── auth_text_field.dart
 │   │           ├── auth_primary_button.dart
 │   │           └── auth_error_view.dart
 │   │
 │   └── tasks/
 │       └── ...
 │
 └── main.dart
```

### Example Mapping

| Clean Architecture Layer           | Flutter Example                  |
| ---------------------------------- | -------------------------------- |
| **Entities**                       | `UserEntity`, `TaskEntity`       |
| **Use Cases**                      | `LoginUser`, `FetchTasks`        |
| **Repositories (Interfaces)**      | `UserRepository` (abstract)      |
| **Data Sources (Implementations)** | `UserRepositoryImpl` calling API |
| **Presentation**                   | `LoginBloc`, `LoginPage`         |

---

## 💻 Step 3: Mini Example

Let’s create a simple *login* flow skeleton to visualize layers.

### 1. Domain layer (`lib/features/auth/domain/`)

```dart
// entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;

  UserEntity({required this.id, required this.email});
}

// repositories/user_repository.dart
abstract class UserRepository {
  Future<UserEntity> login(String email, String password);
}

// usecases/login_user.dart
class LoginUser {
  final UserRepository repository;

  LoginUser(this.repository);

  Future<UserEntity> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
```

### 2. Data layer (`lib/features/auth/data/`)

```dart
// models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email']);
  }
}

// repositories_impl/user_repository_impl.dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
    // mock network call
    await Future.delayed(Duration(milliseconds: 500));
    return UserModel(id: '123', email: email);
  }
}
```

### 3. Presentation layer (`lib/features/auth/presentation/`)

```dart
// bloc/login_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/entities/user_entity.dart';

class LoginCubit extends Cubit<UserEntity?> {
  final LoginUser loginUser;
  LoginCubit(this.loginUser) : super(null);

  Future<void> login(String email, String password) async {
    final user = await loginUser(email, password);
    emit(user);
  }
}
```

That’s the *full vertical slice* — a feature organized by Clean Architecture.

---

## ✏️ Step 4: Create Your Architecture Diagram

Use any of:

* draw.io
* Whimsical / Excalidraw / Canva
* Pen & paper (take a photo, upload to repo)

Structure (example):

```
UI Layer (Flutter Widgets)
    ↓
State Management (BLoC / Riverpod)
    ↓
Use Case Layer (LoginUser)
    ↓
Repository Interface (UserRepository)
    ↓
Data Layer (UserRepositoryImpl → API)
```

Make arrows **only point inward** — nothing in the Domain layer imports Flutter code!

**Label example file names** in boxes to make it concrete.

---

## 🧾 Step 5: Deliverable (repo update)

✅ Add:

```
docs/architecture_diagram.png
docs/clean_arch_notes.md
```

**clean_arch_notes.md** (example):

```md
# Clean Architecture - Flutter Mapping

- Domain: pure business rules, no Flutter dependency.
- Application (UseCases): coordinate business logic.
- Data: implements repositories.
- Presentation: UI + state management.
- Dependency rule: flow inward only.

Feature example: Auth (Login)
UI → Bloc → UseCase → Repository → DataSource
```

Commit message:

```
docs: add Clean Architecture diagram and notes
```

---

## 💡 Bonus (Stretch Learning)

* Watch: Reso Coder — *Clean Architecture in Flutter* (YouTube, 20 min).
* Read: Medium — *Flutter Clean Architecture by Reso Coder* (great diagrams).
* Reflect: “How does my current project violate Clean Architecture boundaries?”

---
## 📅 FAQs

# 📘 **DAY 2 — Clean Architecture Basics (Q&A Guide)**

This document captures all fundamental questions asked about **Clean Architecture**, **Entities vs Models**, **Bloc behavior**, and **feature structuring**.
Use this as your personal architect’s reference.

---

# ## 🧩 **1. What is the difference between Entities and Models? Are they not the same?**

### **Short Answer**

No, they are not the same.
They serve different purposes in Clean Architecture.

### **Entities**

* Represent **business/core meaning** of your data
* Independent from frameworks (Flutter, Firebase, APIs)
* Live in the **domain layer**
* Used by use cases
* No serialization, no `JsonKey`, no frameworks

### **Models**

* Represent **external data format** (API/DB/cache)
* Live in the **data layer**
* Contain `fromJson`, `toJson`, and `@JsonKey`
* Depends on frameworks/libraries
* Maps raw API/DB data → Entity

### **Why separate?**

Because API/DB schema can change but your business logic should NOT break.

---

# ## 🧩 2. If Freezed already supports @JsonKey, do I still need a separate Entity?

### **Yes — in professional apps where architecture matters.**

Freezed helps with:

* serialization
* immutability
* equality

But it does **not** solve:

* API schema changing
* multi-source merging (API + cache)
* domain purity
* testability
* independence from frameworks

### **Rule:**

* **Entity = no serialization**
* **Model = with serialization**

### Exception (allowed):

For very small apps or MVPs → one Freezed class is okay.

---

# ## 🧩 3. Freezed doesn’t support `extends` — so how do Entities relate to Models?

Use **implements**, not extends.

Example:

```dart
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String name,
  }) = _UserEntity;
}
```

```dart
@freezed
class UserModel with _$UserModel implements UserEntity {
  const factory UserModel({
    required String id,
    @JsonKey(name: 'user_name') required String name,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

* Entity → defines business contract
* Model → implements + extends with API details

---

# ## 🧩 4. Can we have Clean Architecture even without separate Entities & Models?

### **Yes.**

You can use Clean Architecture folder structure without separate entity classes.

But:

* Domain becomes framework-dependent
* Future scaling becomes difficult
* Testing becomes harder
* API or DB changes break your domain layer
* You can’t reuse domain logic across platforms

### **Recommendation:**

As a future solution architect → **always separate them** in long-term projects.

---

# ## 🧩 5. What does “Bloc = one behavior domain, not one page” actually mean?

### **Behavior = business goal (verb)**

Not UI events.

Examples of behaviors:

* Login
* Register
* Reset password
* Fetch notifications
* Create report
* Upload file
* Fetch feed
* Like a post

Each behavior is a **complete flow**.

### **Page ≠ Behavior**

A page can contain multiple behaviors.

### **Events = small steps inside a behavior**

Example: Login behavior includes:

* email changed
* password changed
* submit pressed
* loading
* success
* failure

These are **events**, not behaviors.

### **Rule:**

✔ One Behavior = One Bloc
✔ Multiple events = inside one Bloc
✔ One Page = multiple behaviors = multiple blocs

---

# ## 🧩 6. Real World Examples

### **Example 1: Notification page with two tabs (All + Favorites)**

**Behavior?** → Fetch notifications
**Same API?** → Yes
**Same logic?** → Yes

✔ Use **one Bloc** with different parameters.

---

### **Example 2: Report page with two tabs (List + Create)**

Two behaviors:

1. Fetch reports (list)
2. Create a new report (create form)

✔ Use **two Blocs**

---

### **Example 3: Ticket page + Filter page**

* Ticket page shows list → **one behavior: fetchTickets**
* Filter page only updates UI filters → no domain behavior

✔ Use **one TicketBloc**
✔ Filter page uses **simple UI state** (no bloc required)

---

# ## 🧩 7. When to create 1 Bloc vs multiple Blocs?

### ✔ Create **ONE Bloc** if:

* Same business behavior
* Same API
* Only filters change
* Only UI presentation changes

### ✔ Create **MULTIPLE Blocs** if:

* Different verbs/business goals
* List vs Create
* Fetch vs Update
* Upload vs Fetch
* Reset vs Register vs Login

### ✔ Pages do NOT decide bloc boundaries

Behaviors do.

---

# ## 🧩 8. Summary Cheat Rule (remember this forever)

```
Behavior = VERB
Events = STEPS
Pages = UI containers

ONE behavior → ONE Bloc
MULTIPLE behaviors → MULTIPLE Blocs
UI-only pages → NO Bloc needed
```

---