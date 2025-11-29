/// Feature Auth package - Authentication functionality
///
/// This package contains:
/// - Login, Register, Password Reset flows
/// - Domain: UserEntity, UseCases
/// - Data: UserRepository implementation
/// - Presentation: BLoC, Pages
library;

// Domain layer exports
export 'domain/entities/user_entity.dart';
export 'domain/repository/user_repository.dart';
export 'domain/usecases/login_user_use_case.dart';

// Data layer exports (for DI setup)
export 'data/entities/user_entity.dart' show UserModel;
export 'data/repositories_impl/user_repository_impl.dart';

// Presentation layer exports (what the app needs)
export 'presentation/login/bloc/login_bloc.dart';
export 'presentation/login/bloc/login_event.dart';
export 'presentation/login/bloc/login_state.dart';
export 'presentation/login/page/login_page.dart';
