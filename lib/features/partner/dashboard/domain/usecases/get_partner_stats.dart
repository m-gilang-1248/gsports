import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../entities/partner_stats.dart';
import '../repositories/partner_repository.dart';

@lazySingleton
class GetPartnerStats implements UseCase<PartnerStats, String> {
  final PartnerRepository repository;

  GetPartnerStats(this.repository);

  @override
  Future<Either<Failure, PartnerStats>> call(String uid) {
    return repository.getPartnerStats(uid);
  }
}
