part of 'order_management_bloc.dart';

abstract class OrderManagementEvent extends Equatable {
  const OrderManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchPartnerBookings extends OrderManagementEvent {}

class PartnerBookingsUpdated extends OrderManagementEvent {
  final List<Booking> bookings;

  const PartnerBookingsUpdated(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class UpdateCalendarFocusedDay extends OrderManagementEvent {
  final DateTime focusedDay;
  final DateTime? selectedDay;

  const UpdateCalendarFocusedDay(this.focusedDay, this.selectedDay);

  @override
  List<Object?> get props => [focusedDay, selectedDay];
}

class OrderManagementFilterChanged extends OrderManagementEvent {
  final String? venueId;
  final String? courtId;
  final String? sportType;
  final DateTimeRange? dateRange;
  final bool clearAll;

  const OrderManagementFilterChanged({
    this.venueId,
    this.courtId,
    this.sportType,
    this.dateRange,
    this.clearAll = false,
  });

  @override
  List<Object?> get props => [venueId, courtId, sportType, dateRange, clearAll];
}
