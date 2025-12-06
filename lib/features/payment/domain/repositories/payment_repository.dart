import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_info.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentInfo>> createInvoice({
    required String orderId,
    required int amount,
  });

  Future<Either<Failure, String>> getTransactionStatus(String orderId);
}
