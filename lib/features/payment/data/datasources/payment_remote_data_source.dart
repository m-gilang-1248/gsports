import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/error/exceptions.dart';
import '../models/payment_info_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentInfoModel> createTransaction({
    required String orderId,
    required int amount,
  });

  Future<String> getTransactionStatus(String orderId);
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
        'custom_expiry': {
          'order_time': DateTime.now()
              .toUtc()
              .add(const Duration(hours: 7)) // WIB Time
              .toString()
              .split('.')
              .first
              .trim(), // Format: yyyy-MM-dd HH:mm:ss
          'expiry_duration': 15,
          'unit': 'minute',
        },
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

  @override
  Future<String> getTransactionStatus(String orderId) async {
    final serverKey = dotenv.env['MIDTRANS_SERVER_KEY'];
    if (serverKey == null) {
      // In a real app, this should be handled globally or lead to a specific failure state
      return 'cancelled';
    }

    final basicAuth = base64Encode(utf8.encode('$serverKey:'));

    final url = Uri.parse(
      'https://api.sandbox.midtrans.com/v2/$orderId/status',
    );

    try {
      final response = await client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $basicAuth',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['transaction_status'] as String;
      } else if (response.statusCode == 404) {
        // Transaction not found, likely user hasn't selected payment method yet.
        return 'not_found';
      } else {
        // Other API errors, treat as cancelled
        developer.log(
          'DEBUG: Midtrans API Error for orderId $orderId: ${response.statusCode} ${response.body}',
        );
        return 'cancelled';
      }
    } catch (e) {
      // General network or parsing errors, treat as cancelled
      developer.log(
        'DEBUG: General Error getting Midtrans status for orderId $orderId: $e',
      );
      return 'cancelled';
    }
  }
}
