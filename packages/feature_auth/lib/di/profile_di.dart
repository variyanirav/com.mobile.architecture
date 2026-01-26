import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/user_profile_local_datasource.dart';
import '../data/datasources/user_profile_remote_datasource.dart';
import '../data/repositories_impl/user_profile_repository_impl.dart';
import '../domain/repository/user_profile_repository.dart';
import '../presentation/profile/bloc/profile_bloc.dart';

/// Dependency injection setup for Profile feature
/// This demonstrates how to wire up all the layers in Day 7 architecture
class ProfileDI {
  static late UserProfileRepository _repository;
  static late ProfileBloc _profileBloc;
  static bool _initialized = false;

  /// Initialize all dependencies
  /// Call this once at app startup
  static Future<void> initialize() async {
    if (_initialized) return;

    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Create HTTP client
    final httpClient = http.Client();

    // Data layer - Remote & Local data sources
    final remoteDataSource = UserProfileRemoteDataSourceImpl(
      client: httpClient,
    );

    final localDataSource = UserProfileLocalDataSourceImpl(
      sharedPreferences: prefs,
    );

    // Data layer - Repository implementation
    _repository = UserProfileRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    // Presentation layer - BLoC
    _profileBloc = ProfileBloc(repository: _repository);

    _initialized = true;
  }

  /// Get the repository instance
  static UserProfileRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Get the ProfileBloc instance
  static ProfileBloc get profileBloc {
    _ensureInitialized();
    return _profileBloc;
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'ProfileDI not initialized. Call ProfileDI.initialize() first.',
      );
    }
  }

  /// Dispose resources
  static void dispose() {
    if (_initialized) {
      _profileBloc.close();
      _initialized = false;
    }
  }
}
