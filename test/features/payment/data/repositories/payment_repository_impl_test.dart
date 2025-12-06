import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:gsports/features/payment/data/models/payment_info_model.dart';
import 'package:gsports/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:gsports/features/payment/domain/entities/payment_info.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRemoteDataSource extends Mock
    implements PaymentRemoteDataSource {}

void main() {
  late PaymentRepositoryImpl repository;
  late MockPaymentRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPaymentRemoteDataSource();
    repository = PaymentRepositoryImpl(mockRemoteDataSource);
  });

  group('createInvoice', () {
    const tOrderId = 'ORDER-123';
    const tAmount = 100000;
    const tPaymentInfoModel = PaymentInfoModel(
      token: 'snap_token_123',
      redirectUrl: 'https://redirect.url',
    );
    const PaymentInfo tPaymentInfo = tPaymentInfoModel;

    test('should return PaymentInfo when the call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.createTransaction(
              orderId: tOrderId, amount: tAmount))
          .thenAnswer((_) async => tPaymentInfoModel);

      // act
      final result = await repository.createInvoice(
        orderId: tOrderId,
        amount: tAmount,
      );

      // assert
      expect(result, equals(const Right(tPaymentInfo)));
      verify(() => mockRemoteDataSource.createTransaction(
          orderId: tOrderId, amount: tAmount)).called(1);
    });

    test('should return ServerFailure when the call to remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.createTransaction(
              orderId: tOrderId, amount: tAmount))
          .thenThrow(ServerException('Server Error'));

      // act
      final result = await repository.createInvoice(
        orderId: tOrderId,
        amount: tAmount,
      );

      // assert
      expect(result, equals(const Left(ServerFailure('Server Error'))));
    });
  });
}
