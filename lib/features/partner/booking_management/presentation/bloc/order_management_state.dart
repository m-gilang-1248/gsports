part of 'order_management_bloc.dart';

abstract class OrderManagementState extends Equatable {
  const OrderManagementState();

  @override
  List<Object?> get props => [];
}

class OrderManagementInitial extends OrderManagementState {}

class OrderManagementLoading extends OrderManagementState {}

class OrderManagementLoaded extends OrderManagementState {
  final List<Booking> allBookings;
  final List<Booking> pendingBookings;
  final List<Booking> upcomingBookings;
  final List<Booking> historyBookings;
  final Map<DateTime, List<Booking>> bookingsByDate;
  final DateTime focusedDay;
  final DateTime? selectedDay;

  // Inventory Data
  final List<Venue> availableVenues;

  // Filters
  final String? filterVenueId;
  final String? filterCourtId;
  final String? filterSportType;
  final String? filterStatus;
  final DateTimeRange? filterDateRange;

  const OrderManagementLoaded({
    required this.allBookings,
    required this.pendingBookings,
    required this.upcomingBookings,
    required this.historyBookings,
    required this.bookingsByDate,
    required this.focusedDay,
    this.selectedDay,
    this.availableVenues = const [],
    this.filterVenueId,
    this.filterCourtId,
    this.filterSportType,
    this.filterStatus,
    this.filterDateRange,
  });

  OrderManagementLoaded copyWith({
    List<Booking>? allBookings,
    List<Booking>? pendingBookings,
    List<Booking>? upcomingBookings,
    List<Booking>? historyBookings,
    Map<DateTime, List<Booking>>? bookingsByDate,
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<Venue>? availableVenues,
    String? filterVenueId,
    String? filterCourtId,
    String? filterSportType,
    String? filterStatus,
    DateTimeRange? filterDateRange,
  }) {
    return OrderManagementLoaded(
      allBookings: allBookings ?? this.allBookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      bookingsByDate: bookingsByDate ?? this.bookingsByDate,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      availableVenues: availableVenues ?? this.availableVenues,
      filterVenueId: filterVenueId,
      filterCourtId: filterCourtId,
      filterSportType: filterSportType,
      filterStatus: filterStatus,
      filterDateRange: filterDateRange,
    );
  }

  @override
  List<Object?> get props => [
    allBookings,
    pendingBookings,
    upcomingBookings,
    historyBookings,
    bookingsByDate,
    focusedDay,
    selectedDay,
    availableVenues,
    filterVenueId,
    filterCourtId,
    filterSportType,
    filterStatus,
    filterDateRange,
  ];
}

class OrderManagementFailure extends OrderManagementState {
  final String message;

  const OrderManagementFailure(this.message);

  @override
  List<Object?> get props => [message];
}
