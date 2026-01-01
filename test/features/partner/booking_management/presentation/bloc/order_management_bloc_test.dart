import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
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

  final tBooking = Booking(
    id: '1',
    userId: 'u1',
    venueId: 'v1',
    courtId: 'c1',
    sportType: 'futsal',
    date: DateTime.now(),
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 1)),
    durationHours: 1,
    totalPrice: 150000,
    status: 'paid',
    paymentStatus: 'paid',
    createdAt: DateTime.now(),
  );

  final expiredBooking = Booking(
    id: 'exp1',
    userId: 'u1',
    venueId: 'v1',
    courtId: 'c1',
    sportType: 'futsal',
    date: DateTime.now(),
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 1)),
    durationHours: 1,
    totalPrice: 150000,
    status: 'waiting_payment',
    paymentStatus: 'pending',
    createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
  );

  blocTest<OrderManagementBloc, OrderManagementState>(
    'initial state should be OrderManagementInitial',
    build: () => OrderManagementBloc(mockGetPartnerBookings, mockCancelBooking),
    verify: (bloc) => expect(bloc.state, OrderManagementInitial()),
  );

  blocTest<OrderManagementBloc, OrderManagementState>(
    'filters out and cancels expired waiting_payment bookings when stream emits',
    build: () {
      when(
        () => mockCancelBooking(any()),
      ).thenAnswer((_) async => const Right(null));

      return OrderManagementBloc(mockGetPartnerBookings, mockCancelBooking);
    },
    act: (bloc) => bloc.add(PartnerBookingsUpdated([tBooking, expiredBooking])),
    expect: () => [
      isA<OrderManagementLoaded>()
          .having((s) => s.allBookings.length, 'allBookings count', 1)
          .having((s) => s.allBookings.first.id, 'id', '1'),
    ],
    verify: (_) {
      verify(() => mockCancelBooking('exp1')).called(1);
    },
  );
}
