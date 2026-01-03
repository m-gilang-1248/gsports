part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, error, joinSuccess }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<Booking> bookings;
  final List<Booking> filteredHistoryBookings;
  final String? selectedSportId;
  final TimeFilterPreset selectedTimePreset;
  final DateTime? customDate;
  final String? message;
  final String? bookingId; // For joinSuccess

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.bookings = const [],
    this.filteredHistoryBookings = const [],
    this.selectedSportId,
    this.selectedTimePreset = TimeFilterPreset.all,
    this.customDate,
    this.message,
    this.bookingId,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<Booking>? bookings,
    List<Booking>? filteredHistoryBookings,
    String? selectedSportId,
    bool clearSportId = false,
    TimeFilterPreset? selectedTimePreset,
    DateTime? customDate,
    String? message,
    String? bookingId,
  }) {
    return HistoryState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      filteredHistoryBookings:
          filteredHistoryBookings ?? this.filteredHistoryBookings,
      selectedSportId: clearSportId
          ? null
          : (selectedSportId ?? this.selectedSportId),
      selectedTimePreset: selectedTimePreset ?? this.selectedTimePreset,
      customDate: customDate ?? this.customDate,
      message: message ?? this.message,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    filteredHistoryBookings,
    selectedSportId,
    selectedTimePreset,
    customDate,
    message,
    bookingId,
  ];
}
