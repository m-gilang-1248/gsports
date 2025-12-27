part of 'order_management_bloc.dart';

abstract class OrderManagementEvent extends Equatable {
  const OrderManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchPartnerBookings extends OrderManagementEvent {}

class UpdateCalendarFocusedDay extends OrderManagementEvent {
  final DateTime focusedDay;
  final DateTime? selectedDay;

  const UpdateCalendarFocusedDay(this.focusedDay, this.selectedDay);

  @override
  List<Object?> get props => [focusedDay, selectedDay];
}
