/// Feature Auth package - Authentication functionality
///
/// This package contains:
/// - Login, Register, Password Reset flows
/// - Domain: UserEntity, UseCases, Repository
/// - Data: UserModel, Repository implementation
/// - Presentation: BLoC, Pages
library;

// Domain layer exports
export 'domain/entities/user_entity.dart';
export 'domain/repository/auth_repository.dart';
export 'domain/usecases/login_usecase.dart';

// Data layer exports (for DI setup)
export 'data/models/user_model.dart';
export 'data/repository/auth_repository_impl.dart';

// Presentation layer exports (BLoC)
export 'presentation/login/bloc/auth_bloc.dart';
export 'presentation/login/bloc/auth_event.dart';
export 'presentation/login/bloc/auth_state.dart';
export 'presentation/login/bloc/login_event.dart';
export 'presentation/login/bloc/login_state.dart';
export 'presentation/login/page/login_page.dart';
