import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/partner/dashboard/domain/entities/partner_stats.dart';

abstract class PartnerRepository {
  Future<Either<Failure, PartnerStats>> getPartnerStats(String uid);
}
