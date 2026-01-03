import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/constants/filter_constants.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:gsports/features/booking/domain/usecases/join_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/booking/presentation/bloc/history/history_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockGetMyBookings extends Mock implements GetMyBookings {}

class MockJoinBooking extends Mock implements JoinBooking {}

class MockCancelBooking extends Mock implements CancelBooking {}

class FakePaymentParticipant extends Fake implements PaymentParticipant {}

void main() {
  late MockGetMyBookings mockGetMyBookings;
  late MockJoinBooking mockJoinBooking;
  late MockCancelBooking mockCancelBooking;
  late MockFirebaseAuth mockFirebaseAuth;

  const tUserId = 'user123';
  const tSplitCode = 'ABCDEF';

  final tBooking = Booking(
    id: '1',
    userId: tUserId,
    venueId: 'v1',
    courtId: 'c1',
    sportType: 'badminton',
    date: DateTime.now().subtract(const Duration(days: 1)),
    startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    durationHours: 1,
    totalPrice: 100000,
    status: 'paid',
    paymentStatus: 'paid',
    isSplitBill: false,
    participants: const [],
    participantIds: const [],
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  );

  final List<Booking> tBookings = [tBooking];

  setUpAll(() {
    registerFallbackValue(FakePaymentParticipant());
  });

  setUp(() {
    mockGetMyBookings = MockGetMyBookings();
    mockJoinBooking = MockJoinBooking();
    mockCancelBooking = MockCancelBooking();
    mockFirebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: tUserId, displayName: 'Test User'),
    );
  });

  test('initial state should be HistoryState with initial status', () {
    final historyBloc = HistoryBloc(
      getMyBookings: mockGetMyBookings,
      joinBooking: mockJoinBooking,
      cancelBooking: mockCancelBooking,
      firebaseAuth: mockFirebaseAuth,
    );
    expect(historyBloc.state.status, HistoryStatus.initial);
    historyBloc.close();
  });

  blocTest<HistoryBloc, HistoryState>(
    'emits [loading, loaded] when FetchBookingHistory is added and successful',
    build: () {
      when(
        () => mockGetMyBookings(any()),
      ).thenAnswer((_) async => Right(tBookings));
      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking,
        firebaseAuth: mockFirebaseAuth,
      );
    },
    act: (bloc) => bloc.add(const FetchBookingHistory(tUserId)),
    expect: () => [
      const HistoryState(status: HistoryStatus.loading),
      isA<HistoryState>().having(
        (s) => s.status,
        'status',
        HistoryStatus.loaded,
      ),
    ],
    verify: (_) {
      verify(() => mockGetMyBookings(tUserId)).called(1);
    },
  );

  group('Filtering', () {
    final tFutsalBooking = Booking(
      id: '2',
      userId: tUserId,
      venueId: 'v1',
      courtId: 'c2',
      sportType: 'futsal',
      date: DateTime.now().subtract(const Duration(days: 10)),
      startTime: DateTime.now().subtract(const Duration(days: 10, hours: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 10, hours: 1)),
      durationHours: 1,
      totalPrice: 100000,
      status: 'paid',
      paymentStatus: 'paid',
      isSplitBill: false,
      participants: const [],
      participantIds: const [],
      createdAt: DateTime.now().subtract(const Duration(days: 10, hours: 3)),
    );

    blocTest<HistoryBloc, HistoryState>(
      'UpdateBookingSportFilter filters history correctly',
      build: () => HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking,
        firebaseAuth: mockFirebaseAuth,
      ),
      seed: () => HistoryState(
        status: HistoryStatus.loaded,
        bookings: [tBooking, tFutsalBooking],
        filteredHistoryBookings: [tBooking, tFutsalBooking],
      ),
      act: (bloc) => bloc.add(const UpdateBookingSportFilter('futsal')),
      expect: () => [
        isA<HistoryState>()
            .having((s) => s.selectedSportId, 'sportId', 'futsal')
            .having((s) => s.filteredHistoryBookings.length, 'length', 1)
            .having((s) => s.filteredHistoryBookings.first.id, 'id', '2'),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'UpdateBookingTimeFilter filters history correctly (This Week)',
      build: () => HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking,
        firebaseAuth: mockFirebaseAuth,
      ),
      seed: () => HistoryState(
        status: HistoryStatus.loaded,
        bookings: [tBooking, tFutsalBooking],
        filteredHistoryBookings: [tBooking, tFutsalBooking],
      ),
      act: (bloc) => bloc.add(
        const UpdateBookingTimeFilter(preset: TimeFilterPreset.thisWeek),
      ),
      expect: () => [
        isA<HistoryState>()
            .having(
              (s) => s.selectedTimePreset,
              'preset',
              TimeFilterPreset.thisWeek,
            )
            .having((s) => s.filteredHistoryBookings.length, 'length', 1)
            .having((s) => s.filteredHistoryBookings.first.id, 'id', '1'),
      ],
    );
  });
}
