import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:gsports/features/payment/data/models/payment_info_model.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late PaymentRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() async {
    mockHttpClient = MockHttpClient();
    dataSource = PaymentRemoteDataSourceImpl(mockHttpClient);
    registerFallbackValue(Uri());
    // Mock dotenv
    await dotenv.load(fileName: '.env');
    dotenv.env['MIDTRANS_SERVER_KEY'] = 'mock_key';
  });

  group('createTransaction', () {
    const tOrderId = 'ORDER-123';
    const tAmount = 100000;
    const tPaymentInfoModel = PaymentInfoModel(
      token: 'snap_token_123',
      redirectUrl:
          'https://app.sandbox.midtrans.com/snap/v2/vtweb/snap_token_123',
    );

    test(
      'should return PaymentInfoModel when the response code is 201 (Created)',
      () async {
        // arrange
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'token': 'snap_token_123',
              'redirect_url':
                  'https://app.sandbox.midtrans.com/snap/v2/vtweb/snap_token_123',
            }),
            201,
          ),
        );

        // act
        final result = await dataSource.createTransaction(
          orderId: tOrderId,
          amount: tAmount,
        );

        // assert
        expect(result, equals(tPaymentInfoModel));
        verify(
          () => mockHttpClient.post(
            Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).called(1);
      },
    );

    test(
      'should throw ServerException when the response code is not 201',
      () async {
        // arrange
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('Something went wrong', 400));

        // act
        final call = dataSource.createTransaction;

        // assert
        expect(
          () => call(orderId: tOrderId, amount: tAmount),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
