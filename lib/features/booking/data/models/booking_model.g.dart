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
  venueName: json['venueName'] as String?,
  courtName: json['courtName'] as String?,
  venueLocation: json['venueLocation'] as String?,
  midtransOrderId: json['midtransOrderId'] as String?,
  midtransPaymentUrl: json['midtransPaymentUrl'] as String?,
  isSplitBill: json['isSplitBill'] as bool? ?? false,
  splitCode: json['splitCode'] as String?,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map(
            (e) => PaymentParticipantModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
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
      'venueName': instance.venueName,
      'courtName': instance.courtName,
      'venueLocation': instance.venueLocation,
      'midtransOrderId': instance.midtransOrderId,
      'midtransPaymentUrl': instance.midtransPaymentUrl,
      'isSplitBill': instance.isSplitBill,
      'splitCode': instance.splitCode,
      'participantIds': instance.participantIds,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'participants': instance.participants,
    };
