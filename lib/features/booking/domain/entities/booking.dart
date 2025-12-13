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

  // Optional fields for Midtrans and Split Bill
  final String? midtransOrderId;
  final String? midtransPaymentUrl;
  final bool isSplitBill;
  final String? splitCode;
  final List<PaymentParticipant> participants;
  final List<String> participantIds;

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
    this.midtransOrderId,
    this.midtransPaymentUrl,
    this.isSplitBill = false,
    this.splitCode,
    this.participants = const [],
    this.participantIds = const [],
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
    midtransOrderId,
    midtransPaymentUrl,
    isSplitBill,
    splitCode,
    participants,
    participantIds,
  ];
}
