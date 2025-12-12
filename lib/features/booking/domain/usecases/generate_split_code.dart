import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/booking_repository.dart';

@injectable
class GenerateSplitCode {
  final BookingRepository repository;

  GenerateSplitCode(this.repository);

  Future<Either<Failure, void>> call(String bookingId) async {
    return await repository.generateSplitCode(bookingId);
  }
}
