import 'package:core/core.dart';
import 'package:feature_auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<Failure, UserEntity>> login(String email, String password);
}
