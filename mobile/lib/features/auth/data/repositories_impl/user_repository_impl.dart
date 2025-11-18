import 'package:mobile/features/auth/data/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
    // mock network call
    await Future.delayed(Duration(milliseconds: 500));
    return UserModel(id: '123', email: email);
  }
}
