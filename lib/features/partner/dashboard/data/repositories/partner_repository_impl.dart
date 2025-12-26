import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/partner/dashboard/data/datasources/partner_remote_data_source.dart';
import 'package:gsports/features/partner/dashboard/domain/entities/partner_stats.dart';
import 'package:gsports/features/partner/dashboard/domain/repositories/partner_repository.dart';

@Injectable(as: PartnerRepository)
class PartnerRepositoryImpl implements PartnerRepository {
  final PartnerRemoteDataSource remoteDataSource;

  PartnerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PartnerStats>> getPartnerStats(String uid) async {
    try {
      final bookings = await remoteDataSource.getPartnerBookings(uid);

      int totalRevenue = 0;
      for (final booking in bookings) {
        if (booking.paymentStatus == 'paid' ||
            booking.paymentStatus == 'settled') {
          totalRevenue += booking.totalPrice;
        }
      }

      final recentTransactions = bookings.take(5).toList();

      return Right(
        PartnerStats(
          totalBookings: bookings.length,
          totalRevenue: totalRevenue,
          recentTransactions: recentTransactions,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
