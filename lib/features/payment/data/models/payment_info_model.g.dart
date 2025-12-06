// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentInfoModel _$PaymentInfoModelFromJson(Map<String, dynamic> json) =>
    PaymentInfoModel(
      token: json['token'] as String,
      redirectUrl: json['redirect_url'] as String,
    );

Map<String, dynamic> _$PaymentInfoModelToJson(PaymentInfoModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'redirect_url': instance.redirectUrl,
    };
