part of 'availability_bloc.dart';

abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class AvailabilityInit extends AvailabilityEvent {}

class AvailabilityVenueSelected extends AvailabilityEvent {
  final Venue venue;
  const AvailabilityVenueSelected(this.venue);

  @override
  List<Object?> get props => [venue];
}

class AvailabilityCourtSelected extends AvailabilityEvent {
  final Court? court;
  const AvailabilityCourtSelected(this.court);

  @override
  List<Object?> get props => [court];
}

class AvailabilitySportTypeSelected extends AvailabilityEvent {
  final String? sportType;
  const AvailabilitySportTypeSelected(this.sportType);

  @override
  List<Object?> get props => [sportType];
}

class AvailabilityMonthChanged extends AvailabilityEvent {
  final DateTime focusedDay;
  const AvailabilityMonthChanged(this.focusedDay);

  @override
  List<Object?> get props => [focusedDay];
}

class AvailabilityAddBlock extends AvailabilityEvent {
  final DateTime date;
  const AvailabilityAddBlock(this.date);

  @override
  List<Object?> get props => [date];
}
