import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class RegisterUser extends UseCase<UserEntity, RegisterUserParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterUserParams params) async {
    return await repository.registerWithEmailPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      role: params.role,
    );
  }
}

class RegisterUserParams {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const RegisterUserParams({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'user',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegisterUserParams &&
        other.email == email &&
        other.password == password &&
        other.displayName == displayName &&
        other.role == role;
  }

  @override
  int get hashCode =>
      email.hashCode ^ password.hashCode ^ displayName.hashCode ^ role.hashCode;
}
