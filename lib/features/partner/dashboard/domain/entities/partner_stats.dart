import 'package:equatable/equatable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';

class PartnerStats extends Equatable {
  final int totalBookings;
  final int totalRevenue;
  final List<Booking> recentTransactions;
  final List<Booking> allBookings;

  const PartnerStats({
    required this.totalBookings,
    required this.totalRevenue,
    required this.recentTransactions,
    required this.allBookings,
  });

  @override
  List<Object?> get props => [
    totalBookings,
    totalRevenue,
    recentTransactions,
    allBookings,
  ];
}
