import 'package:equatable/equatable.dart';

class PaymentInfo extends Equatable {
  final String token;
  final String redirectUrl;

  const PaymentInfo({required this.token, required this.redirectUrl});

  @override
  List<Object?> get props => [token, redirectUrl];
}
