import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<Failure, UserEntity>> login(String email, String password);
}
