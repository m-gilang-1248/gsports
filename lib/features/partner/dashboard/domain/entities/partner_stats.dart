import 'package:equatable/equatable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';

class PartnerStats extends Equatable {
  final int totalBookings;
  final int totalRevenue;
  final List<Booking> recentTransactions;

  const PartnerStats({
    required this.totalBookings,
    required this.totalRevenue,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [totalBookings, totalRevenue, recentTransactions];
}
