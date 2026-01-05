import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_partner_bookings.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/get_my_venues.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPartnerBookings extends Mock implements GetPartnerBookings {}

class MockCancelBooking extends Mock implements CancelBooking {}

class MockGetMyVenues extends Mock implements GetMyVenues {}

void main() {
  late MockGetPartnerBookings mockGetPartnerBookings;
  late MockCancelBooking mockCancelBooking;
  late MockGetMyVenues mockGetMyVenues;

  setUp(() {
    mockGetPartnerBookings = MockGetPartnerBookings();
    mockCancelBooking = MockCancelBooking();
    mockGetMyVenues = MockGetMyVenues();
  });

  final now = DateTime.now();
  final future1 = now.add(const Duration(days: 1));
  final future2 = now.add(const Duration(days: 2));

  final b1 = Booking(
    id: '1',
    userId: 'u1',
    venueId: 'v1',
    venueName: 'Venue A',
    courtId: 'c1',
    courtName: 'Court 1',
    sportType: 'badminton',
    date: future1,
    startTime: future1,
    endTime: future1.add(const Duration(hours: 1)),
    durationHours: 1,
    totalPrice: 50000,
    status: 'paid',
    paymentStatus: 'paid',
    createdAt: now,
  );

  final b2 = Booking(
    id: '2',
    userId: 'u2',
    venueId: 'v2',
    venueName: 'Venue B',
    courtId: 'c2',
    courtName: 'Court 2',
    sportType: 'futsal',
    date: future2,
    startTime: future2,
    endTime: future2.add(const Duration(hours: 1)),
    durationHours: 1,
    totalPrice: 150000,
    status: 'waiting_payment',
    paymentStatus: 'pending',
    createdAt: now,
  );

  group('OrderManagementBloc Advanced Filtering', () {
    blocTest<OrderManagementBloc, OrderManagementState>(
      'filters bookings locally by status',
      build: () => OrderManagementBloc(
        mockGetPartnerBookings,
        mockCancelBooking,
        mockGetMyVenues,
      ),
      seed: () => OrderManagementLoaded(
        allBookings: [b1, b2],
        pendingBookings: [b2],
        upcomingBookings: [b1],
        historyBookings: const [],
        bookingsByDate: const {},
        focusedDay: DateTime.now(),
      ),
      act: (bloc) =>
          bloc.add(const OrderManagementFilterChanged(status: 'paid')),
      expect: () => [
        isA<OrderManagementLoaded>()
            .having((s) => s.filterStatus, 'filterStatus', 'paid')
            .having((s) => s.upcomingBookings.length, 'filtered upcoming', 1)
            .having((s) => s.pendingBookings.length, 'filtered pending', 0),
      ],
    );

    blocTest<OrderManagementBloc, OrderManagementState>(
      'clears filters correctly',
      build: () => OrderManagementBloc(
        mockGetPartnerBookings,
        mockCancelBooking,
        mockGetMyVenues,
      ),
      seed: () => OrderManagementLoaded(
        allBookings: [b1, b2],
        pendingBookings: const [],
        upcomingBookings: [b1],
        historyBookings: const [],
        bookingsByDate: const {},
        focusedDay: DateTime.now(),
        filterStatus: 'paid',
      ),
      act: (bloc) =>
          bloc.add(const OrderManagementFilterChanged(clearAll: true)),
      expect: () => [
        isA<OrderManagementLoaded>()
            .having((s) => s.filterStatus, 'filterStatus', null)
            .having((s) => s.pendingBookings.length, 'pending count', 1),
      ],
    );
  });
}
