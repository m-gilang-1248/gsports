import 'package:equatable/equatable.dart';
import 'payment_participant.dart';

class Booking extends Equatable {
  final String id;
  final String userId;
  final String venueId;
  final String courtId;
  final String sportType;
  final DateTime date; // YYYY-MM-DD 00:00:00
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final int totalPrice;
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
    required this.courtId,
    required this.sportType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
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

  @override
  List<Object?> get props => [
    id,
    userId,
    venueId,
    courtId,
    sportType,
    date,
    startTime,
    endTime,
    durationHours,
    totalPrice,
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
