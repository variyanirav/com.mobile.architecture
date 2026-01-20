import '../../domain/entities/user_entity.dart';

/// Data model for User
/// Extends UserEntity and adds JSON serialization
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'avatarUrl': avatarUrl};
  }

  /// Convert to domain entity
  UserEntity toEntity() =>
      UserEntity(id: id, email: email, name: name, avatarUrl: avatarUrl);
}
