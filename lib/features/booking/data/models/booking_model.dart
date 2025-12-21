import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/booking.dart';
import 'payment_participant_model.dart';

part 'booking_model.g.dart';

// Custom converter for DateTime to Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
@TimestampConverter() // Apply converter to the entire class
class BookingModel extends Booking {
  @override
  @JsonKey(
    includeToJson: true,
  ) // Ensure participants are included if overridden
  final List<PaymentParticipantModel> participants;

  const BookingModel({
    required super.id,
    required super.userId,
    required super.venueId,
    required super.courtId,
    required super.sportType,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.durationHours,
    required super.totalPrice,
    required super.status,
    required super.paymentStatus,
    super.midtransOrderId,
    super.midtransPaymentUrl,
    super.isSplitBill = false,
    super.splitCode,
    this.participants = const [],
    super.participantIds = const [],
    required super.createdAt,
  }) : super(participants: participants);

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] as String,
      venueId: data['venueId'] as String,
      courtId: data['courtId'] as String,
      sportType: data['sportType'] as String,
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      durationHours: (data['durationHours'] as num).toInt(),
      totalPrice: (data['totalPrice'] as num).toInt(),
      status: data['status'] as String,
      paymentStatus: data['paymentStatus'] as String,
      midtransOrderId: data['midtransOrderId'] as String?,
      midtransPaymentUrl: data['midtransPaymentUrl'] as String?,
      isSplitBill: data['isSplitBill'] as bool? ?? false,
      splitCode: data['splitCode'] as String?,
      participants:
          (data['participants'] as List?)
              ?.map(
                (e) =>
                    PaymentParticipantModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      participantIds:
          (data['participantIds'] as List?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['startTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = _$BookingModelToJson(this);
    // Explicitly handle participants serialization
    json['participants'] = participants.map((p) => p.toJson()).toList();
    json['participantIds'] = participantIds;
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
