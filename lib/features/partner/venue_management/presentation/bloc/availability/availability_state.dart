part of 'availability_bloc.dart';

abstract class AvailabilityState extends Equatable {
  const AvailabilityState();

  @override
  List<Object?> get props => [];
}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilityLoaded extends AvailabilityState {
  final List<Venue> venues;
  final Venue? selectedVenue;
  final List<Court> courts;
  final Court? selectedCourt;
  final List<Booking> maintenanceBookings;
  final DateTime focusedDay;

  const AvailabilityLoaded({
    this.venues = const [],
    this.selectedVenue,
    this.courts = const [],
    this.selectedCourt,
    this.maintenanceBookings = const [],
    required this.focusedDay,
  });

  AvailabilityLoaded copyWith({
    List<Venue>? venues,
    Venue? selectedVenue,
    List<Court>? courts,
    Court?
    selectedCourt, // Nullable override needs care, usually Wrapper or separated
    bool clearSelectedCourt = false,
    List<Booking>? maintenanceBookings,
    DateTime? focusedDay,
  }) {
    return AvailabilityLoaded(
      venues: venues ?? this.venues,
      selectedVenue: selectedVenue ?? this.selectedVenue,
      courts: courts ?? this.courts,
      selectedCourt: clearSelectedCourt
          ? null
          : (selectedCourt ?? this.selectedCourt),
      maintenanceBookings: maintenanceBookings ?? this.maintenanceBookings,
      focusedDay: focusedDay ?? this.focusedDay,
    );
  }

  @override
  List<Object?> get props => [
    venues,
    selectedVenue,
    courts,
    selectedCourt,
    maintenanceBookings,
    focusedDay,
  ];
}

class AvailabilityError extends AvailabilityState {
  final String message;
  const AvailabilityError(this.message);

  @override
  List<Object?> get props => [message];
}
