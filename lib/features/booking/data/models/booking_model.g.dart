// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  venueId: json['venueId'] as String,
  courtId: json['courtId'] as String,
  sportType: json['sportType'] as String,
  date: const TimestampConverter().fromJson(json['date'] as Timestamp),
  startTime: const TimestampConverter().fromJson(
    json['startTime'] as Timestamp,
  ),
  endTime: const TimestampConverter().fromJson(json['endTime'] as Timestamp),
  durationHours: (json['durationHours'] as num).toInt(),
  totalPrice: (json['totalPrice'] as num).toInt(),
  status: json['status'] as String,
  paymentStatus: json['paymentStatus'] as String,
  midtransOrderId: json['midtransOrderId'] as String?,
  midtransPaymentUrl: json['midtransPaymentUrl'] as String?,
  isSplitBill: json['isSplitBill'] as bool? ?? false,
  splitCode: json['splitCode'] as String?,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'venueId': instance.venueId,
      'courtId': instance.courtId,
      'sportType': instance.sportType,
      'date': const TimestampConverter().toJson(instance.date),
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': const TimestampConverter().toJson(instance.endTime),
      'durationHours': instance.durationHours,
      'totalPrice': instance.totalPrice,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'midtransOrderId': instance.midtransOrderId,
      'midtransPaymentUrl': instance.midtransPaymentUrl,
      'isSplitBill': instance.isSplitBill,
      'splitCode': instance.splitCode,
      'participants': instance.participants,
    };
