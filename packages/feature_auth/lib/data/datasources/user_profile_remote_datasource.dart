import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/user_profile_dto.dart';

/// Custom exceptions for data source errors
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

/// Remote data source for user profile
/// In real app, this would call actual API
abstract class UserProfileRemoteDataSource {
  Future<UserProfileDTO> getProfile(String userId);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  UserProfileRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://api.example.com',
  });

  @override
  Future<UserProfileDTO> getProfile(String userId) async {
    try {
      // MOCK API CALL - Simulates real API with various scenarios
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay

      // Randomly simulate different scenarios for demonstration
      final random = Random();
      final scenario = random.nextInt(10);

      if (scenario < 7) {
        // 70% - Success
        return _mockSuccessResponse(userId);
      } else if (scenario == 7) {
        // 10% - Garbage data (missing required fields)
        return _mockGarbageResponse();
      } else if (scenario == 8) {
        // 10% - Server error
        throw ServerException('Internal server error', statusCode: 500);
      } else {
        // 10% - Network timeout
        throw NetworkException('Request timeout');
      }

      // Real API call would look like this:
      /*
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfileDTO.fromJson(json['data']);
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error', statusCode: response.statusCode);
      } else {
        throw ServerException('Failed to load profile', statusCode: response.statusCode);
      }
      */
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  // MOCK RESPONSES for demonstration

  UserProfileDTO _mockSuccessResponse(String userId) {
    return UserProfileDTO(
      userId: userId,
      emailAddress: 'john.doe@example.com',
      displayName: 'John Doe',
      avatarUrl: 'https://i.pravatar.cc/150?img=${userId.hashCode % 70}',
      memberSince: '2024-01-15T10:30:00Z',
      lastLoginAt: DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
      isActive: 1,
      emailVerified: true,
      preferences: const UserPreferencesDTO(
        theme: 'dark',
        notificationsEnabled: true,
      ),
    );
  }

  UserProfileDTO _mockGarbageResponse() {
    // Simulate backend sending garbage (missing required fields)
    return const UserProfileDTO(
      userId: null, // ❌ Required field missing!
      emailAddress: null, // ❌ Required field missing!
      displayName: 'Some User',
      avatarUrl: 'invalid-url',
      memberSince: 'yesterday', // ❌ Invalid date format!
      lastLoginAt: null,
      isActive: 999, // ❌ Should be 0 or 1!
      emailVerified: null,
      preferences: null,
    );
  }
}
