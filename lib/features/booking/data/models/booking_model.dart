import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/booking.dart';

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
  @JsonKey(includeToJson: false) // ID is from doc.id, not in json data
  final String id;
  @override
  final String userId;
  @override
  final String venueId;
  @override
  final String courtId;
  @override
  final String sportType;
  @override
  final DateTime date;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final int durationHours;
  @override
  final int totalPrice;
  @override
  final String status;
  @override
  final String paymentStatus;
  @override
  final String? midtransOrderId;
  @override
  final String? midtransPaymentUrl;
  @override
  final bool isSplitBill;
  @override
  final String? splitCode;
  @override
  final List<Map<String, dynamic>> participants;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.courtId,
    required this.sportType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.midtransOrderId,
    this.midtransPaymentUrl,
    this.isSplitBill = false,
    this.splitCode,
    this.participants = const [],
  }) : super(
         id: id,
         userId: userId,
         venueId: venueId,
         courtId: courtId,
         sportType: sportType,
         date: date,
         startTime: startTime,
         endTime: endTime,
         durationHours: durationHours,
         totalPrice: totalPrice,
         status: status,
         paymentStatus: paymentStatus,
         midtransOrderId: midtransOrderId,
         midtransPaymentUrl: midtransPaymentUrl,
         isSplitBill: isSplitBill,
         splitCode: splitCode,
         participants: participants,
       );

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
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);
}
