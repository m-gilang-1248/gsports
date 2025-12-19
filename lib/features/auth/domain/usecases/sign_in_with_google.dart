import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInWithGoogle implements UseCase<UserEntity, SignInWithGoogleParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithGoogleParams params) async {
    return await repository.signInWithGoogle(role: params.role);
  }
}

class SignInWithGoogleParams {
  final String? role;

  const SignInWithGoogleParams({this.role});
}