part of 'order_management_bloc.dart';

abstract class OrderManagementEvent extends Equatable {
  const OrderManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchPartnerBookings extends OrderManagementEvent {}

class PartnerBookingsUpdated extends OrderManagementEvent {
  final List<Booking> bookings;
  final List<Venue> venues;

  const PartnerBookingsUpdated(this.bookings, {this.venues = const []});

  @override
  List<Object?> get props => [bookings, venues];
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
  final String? status;
  final DateTimeRange? dateRange;
  final bool clearAll;
  final bool clearDate;

  const OrderManagementFilterChanged({
    this.venueId,
    this.courtId,
    this.sportType,
    this.status,
    this.dateRange,
    this.clearAll = false,
    this.clearDate = false,
  });

  @override
  List<Object?> get props => [
    venueId,
    courtId,
    sportType,
    status,
    dateRange,
    clearAll,
    clearDate,
  ];
}
