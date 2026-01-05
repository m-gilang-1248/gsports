import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_partner_bookings.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPartnerBookings extends Mock implements GetPartnerBookings {}

class MockCancelBooking extends Mock implements CancelBooking {}

void main() {
  late MockGetPartnerBookings mockGetPartnerBookings;
  late MockCancelBooking mockCancelBooking;

  setUp(() {
    mockGetPartnerBookings = MockGetPartnerBookings();
    mockCancelBooking = MockCancelBooking();
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
    status: 'paid',
    paymentStatus: 'paid',
    createdAt: now,
  );

  group('OrderManagementBloc Filtering', () {
    blocTest<OrderManagementBloc, OrderManagementState>(
      'filters bookings locally by venueId',
      build: () =>
          OrderManagementBloc(mockGetPartnerBookings, mockCancelBooking),
      seed: () => OrderManagementLoaded(
        allBookings: [b1, b2],
        pendingBookings: const [],
        upcomingBookings: [b1, b2],
        historyBookings: const [],
        bookingsByDate: const {},
        focusedDay: DateTime.now(),
      ),
      act: (bloc) =>
          bloc.add(const OrderManagementFilterChanged(venueId: 'v1')),
      expect: () => [
        isA<OrderManagementLoaded>()
            .having((s) => s.filterVenueId, 'filterVenueId', 'v1')
            .having((s) => s.upcomingBookings.length, 'filtered count', 1)
            .having((s) => s.upcomingBookings.first.venueId, 'venueId', 'v1'),
      ],
    );

    blocTest<OrderManagementBloc, OrderManagementState>(
      'filters bookings locally by sportType',
      build: () =>
          OrderManagementBloc(mockGetPartnerBookings, mockCancelBooking),
      seed: () => OrderManagementLoaded(
        allBookings: [b1, b2],
        pendingBookings: const [],
        upcomingBookings: [b1, b2],
        historyBookings: const [],
        bookingsByDate: const {},
        focusedDay: DateTime.now(),
      ),
      act: (bloc) =>
          bloc.add(const OrderManagementFilterChanged(sportType: 'futsal')),
      expect: () => [
        isA<OrderManagementLoaded>()
            .having((s) => s.filterSportType, 'filterSportType', 'futsal')
            .having((s) => s.upcomingBookings.length, 'filtered count', 1)
            .having(
              (s) => s.upcomingBookings.first.sportType,
              'sportType',
              'futsal',
            ),
      ],
    );

    blocTest<OrderManagementBloc, OrderManagementState>(
      'filters bookings locally by date range',
      build: () =>
          OrderManagementBloc(mockGetPartnerBookings, mockCancelBooking),
      seed: () => OrderManagementLoaded(
        allBookings: [b1, b2],
        pendingBookings: const [],
        upcomingBookings: [b1, b2],
        historyBookings: const [],
        bookingsByDate: const {},
        focusedDay: DateTime.now(),
      ),
      act: (bloc) => bloc.add(
        OrderManagementFilterChanged(
          dateRange: DateTimeRange(
            start: future2.subtract(const Duration(hours: 1)),
            end: future2.add(const Duration(hours: 1)),
          ),
        ),
      ),
      expect: () => [
        isA<OrderManagementLoaded>()
            .having((s) => s.upcomingBookings.length, 'filtered count', 1)
            .having((s) => s.upcomingBookings.first.id, 'id', '2'),
      ],
    );

    blocTest<OrderManagementBloc, OrderManagementState>(
      'clears filters when clearAll is true',
      build: () =>
          OrderManagementBloc(mockGetPartnerBookings, mockCancelBooking),
      seed: () => OrderManagementLoaded(
        allBookings: [b1, b2],
        pendingBookings: const [],
        upcomingBookings: [b1],
        historyBookings: const [],
        bookingsByDate: const {},
        focusedDay: DateTime.now(),
        filterVenueId: 'v1',
      ),
      act: (bloc) =>
          bloc.add(const OrderManagementFilterChanged(clearAll: true)),
      expect: () => [
        isA<OrderManagementLoaded>()
            .having((s) => s.filterVenueId, 'filterVenueId', null)
            .having((s) => s.upcomingBookings.length, 'count', 2),
      ],
    );
  });
}
