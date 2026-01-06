import 'package:equatable/equatable.dart';
import 'payment_participant.dart';

class Booking extends Equatable {
  final String id;
  final String userId;
  final String venueId;
  final String? ownerId; // Added ownerId
  final String courtId;
  final String sportType;
  final DateTime date; // YYYY-MM-DD 00:00:00
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final int totalPrice;
  final int? courtPrice;
  final int? serviceFee;
  final int? appFee;
  final int? netRevenue;
  final String status; // 'waiting_payment', 'confirmed', etc.
  final String paymentStatus; // 'unpaid', 'paid', 'refunded'

  // Denormalized fields for UI performance
  final String? venueName;
  final String? courtName;
  final String? venueLocation;

  // Optional fields for Midtrans and Split Bill
  final String? midtransOrderId;
  final String? midtransPaymentUrl;
  final bool isSplitBill;
  final String? splitCode;
  final List<PaymentParticipant> participants;
  final List<String> participantIds;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.venueId,
    this.ownerId,
    required this.courtId,
    required this.sportType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    this.courtPrice,
    this.serviceFee,
    this.appFee,
    this.netRevenue,
    required this.status,
    required this.paymentStatus,
    this.venueName,
    this.courtName,
    this.venueLocation,
    this.midtransOrderId,
    this.midtransPaymentUrl,
    this.isSplitBill = false,
    this.splitCode,
    this.participants = const [],
    this.participantIds = const [],
    required this.createdAt,
  });

  Booking copyWith({
    String? id,
    String? userId,
    String? venueId,
    String? ownerId,
    String? courtId,
    String? sportType,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? durationHours,
    int? totalPrice,
    int? courtPrice,
    int? serviceFee,
    int? appFee,
    int? netRevenue,
    String? status,
    String? paymentStatus,
    String? venueName,
    String? courtName,
    String? venueLocation,
    String? midtransOrderId,
    String? midtransPaymentUrl,
    bool? isSplitBill,
    String? splitCode,
    List<PaymentParticipant>? participants,
    List<String>? participantIds,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      venueId: venueId ?? this.venueId,
      ownerId: ownerId ?? this.ownerId,
      courtId: courtId ?? this.courtId,
      sportType: sportType ?? this.sportType,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalPrice: totalPrice ?? this.totalPrice,
      courtPrice: courtPrice ?? this.courtPrice,
      serviceFee: serviceFee ?? this.serviceFee,
      appFee: appFee ?? this.appFee,
      netRevenue: netRevenue ?? this.netRevenue,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      venueName: venueName ?? this.venueName,
      courtName: courtName ?? this.courtName,
      venueLocation: venueLocation ?? this.venueLocation,
      midtransOrderId: midtransOrderId ?? this.midtransOrderId,
      midtransPaymentUrl: midtransPaymentUrl ?? this.midtransPaymentUrl,
      isSplitBill: isSplitBill ?? this.isSplitBill,
      splitCode: splitCode ?? this.splitCode,
      participants: participants ?? this.participants,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    venueId,
    ownerId,
    courtId,
    sportType,
    date,
    startTime,
    endTime,
    durationHours,
    totalPrice,
    courtPrice,
    serviceFee,
    appFee,
    netRevenue,
    status,
    paymentStatus,
    venueName,
    courtName,
    venueLocation,
    midtransOrderId,
    midtransPaymentUrl,
    isSplitBill,
    splitCode,
    participants,
    participantIds,
    createdAt,
  ];
}
