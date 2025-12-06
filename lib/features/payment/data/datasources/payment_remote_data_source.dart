import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/payment_info_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentInfoModel> createTransaction({
    required String orderId,
    required int amount,
  });
}

@LazySingleton(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final http.Client client;

  PaymentRemoteDataSourceImpl(this.client);

  @override
  Future<PaymentInfoModel> createTransaction({
    required String orderId,
    required int amount,
  }) async {
    final serverKey = dotenv.env['MIDTRANS_SERVER_KEY'];
    if (serverKey == null) {
      throw ServerException('MIDTRANS_SERVER_KEY not found');
    }

    // Basic Auth: base64("Key:")
    final basicAuth = base64Encode(utf8.encode('$serverKey:'));

    final url = Uri.parse(
      'https://app.sandbox.midtrans.com/snap/v1/transactions',
    );

    final response = await client.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Basic $basicAuth',
      },
      body: jsonEncode({
        'transaction_details': {'order_id': orderId, 'gross_amount': amount},
        'credit_card': {'secure': true},
      }),
    );

    if (response.statusCode == 201) {
      return PaymentInfoModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        'Failed to create Midtrans transaction: ${response.statusCode} ${response.body}',
      );
    }
  }
}
