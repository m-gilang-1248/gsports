import 'package:injectable/injectable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../entities/user_stats.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetUserStats implements UseCase<UserStats, String> {
  final ProfileRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, UserStats>> call(String uid) {
    return repository.getUserStats(uid);
  }
}
