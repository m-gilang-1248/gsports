import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateFcmToken implements UseCase<void, UpdateFcmTokenParams> {
  final AuthRepository repository;

  UpdateFcmToken(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateFcmTokenParams params) async {
    return await repository.updateFcmToken(params.token);
  }
}

class UpdateFcmTokenParams extends Equatable {
  final String token;

  const UpdateFcmTokenParams({required this.token});

  @override
  List<Object?> get props => [token];
}
