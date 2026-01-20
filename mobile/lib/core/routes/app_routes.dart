/// Route paths for the application
/// Use these constants instead of magic strings for type safety
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Auth routes (public)
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // App routes (require authentication)
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Deep link routes with parameters
  static String resetPassword(String token) => '/reset-password/$token';
  static String productDetail(String id) => '/product/$id';
}
