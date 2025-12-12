// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_participant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentParticipantModel _$PaymentParticipantModelFromJson(
  Map<String, dynamic> json,
) => PaymentParticipantModel(
  uid: json['uid'] as String?,
  name: json['name'] as String,
  status: json['status'] as String,
  paymentStatusToHost: json['paymentStatusToHost'] as String,
  profileUrl: json['profileUrl'] as String?,
);

Map<String, dynamic> _$PaymentParticipantModelToJson(
  PaymentParticipantModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'status': instance.status,
  'paymentStatusToHost': instance.paymentStatusToHost,
  'profileUrl': instance.profileUrl,
};
