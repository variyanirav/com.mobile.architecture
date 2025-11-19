# Clean Architecture Diagram - Flutter Auth Feature

## Layer Flow (Dependency Rule: Inner layers never depend on outer layers)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                            │
│                         (Framework & UI)                             │
│                                                                       │
│  ┌──────────────┐         ┌─────────────┐       ┌─────────────┐    │
│  │  LoginPage   │────────▶│  LoginBloc  │◀──────│ LoginEvent  │    │
│  │  (Widget)    │         │             │       │ LoginState  │    │
│  └──────────────┘         └─────────────┘       └─────────────┘    │
│                                   │                                  │
└───────────────────────────────────┼──────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER                             │
│                           (Use Cases)                                │
│                                                                       │
│                        ┌─────────────┐                               │
│                        │  LoginUser  │                               │
│                        │  (UseCase)  │                               │
│                        └─────────────┘                               │
│                                │                                     │
└────────────────────────────────┼─────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                                │
│                      (Business Logic Core)                           │
│                                                                       │
│  ┌──────────────┐              ┌────────────────────┐               │
│  │ UserEntity   │              │ UserRepository     │               │
│  │ (Pure Model) │              │ (Interface)        │               │
│  └──────────────┘              └────────────────────┘               │
│                                         ▲                            │
└─────────────────────────────────────────┼────────────────────────────┘
                                          │
                                          │ implements
                                          │
┌─────────────────────────────────────────┼────────────────────────────┐
│                          DATA LAYER                                  │
│                    (External Interfaces)                             │
│                                          │                            │
│  ┌───────────────────────┐      ┌───────┴────────────┐              │
│  │      UserModel        │      │ UserRepositoryImpl │              │
│  │ (Entity + JSON logic) │◀─────│  (API/DB calls)    │              │
│  └───────────────────────┘      └────────────────────┘              │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                                          │
                                          ▼
                                  ┌──────────────┐
                                  │ External API │
                                  │ / Database   │
                                  └──────────────┘
```

## File Mapping

### Presentation Layer (`lib/features/auth/presentation/`)
- **LoginPage** → `pages/login_page.dart`
- **LoginBloc** → `bloc/login_bloc.dart`
- **LoginEvent** → `bloc/login_event.dart`
- **LoginState** → `bloc/login_state.dart`

### Application Layer (`lib/features/auth/domain/usecases/`)
- **LoginUser** → `login_user.dart`

### Domain Layer (`lib/features/auth/domain/`)
- **UserEntity** → `entities/user_entity.dart`
- **UserRepository** → `repositories/user_repository.dart`

### Data Layer (`lib/features/auth/data/`)
- **UserModel** → `entities/user_model.dart`
- **UserRepositoryImpl** → `repositories_impl/user_repository_impl.dart`

## Dependency Flow

```
UI Layer (Flutter Widgets)
    ↓
State Management (BLoC)
    ↓
Use Case Layer (LoginUser)
    ↓
Repository Interface (UserRepository - abstract)
    ↓
Data Layer (UserRepositoryImpl → API)
```

## Key Principles

1. **Dependency Direction**: Always inward (outer depends on inner, never reverse)
2. **Domain Independence**: Core business logic has NO Flutter dependencies
3. **Interface Segregation**: Repository defined in domain, implemented in data
4. **Single Responsibility**: Each layer has one reason to change
5. **Testability**: Each layer can be tested in isolation

## Example Flow: User Clicks Login Button

```
1. LoginPage (UI) → Dispatches LoginSubmitted event
2. LoginBloc (Presentation) → Receives event, calls LoginUser use case
3. LoginUser (Application) → Executes business logic, calls repository
4. UserRepository (Domain) → Interface contract
5. UserRepositoryImpl (Data) → Makes actual API call, converts JSON to UserModel
6. UserModel → Extends UserEntity, returns pure entity up the chain
7. LoginBloc → Emits LoginSuccess with UserEntity
8. LoginPage → Listens to state, displays success UI
```

## Violations to Avoid

❌ **NEVER** import Flutter in domain layer
❌ **NEVER** import data layer in presentation
❌ **NEVER** import use cases directly in UI (always through Bloc/Cubit)
❌ **NEVER** put business logic in Bloc (belongs in use cases)

✅ **ALWAYS** use dependency injection
✅ **ALWAYS** depend on abstractions (interfaces)
✅ **ALWAYS** keep entities pure (no serialization)
✅ **ALWAYS** separate concerns by layer
