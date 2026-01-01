import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:gsports/features/booking/domain/usecases/join_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart'; // Added
import 'package:gsports/features/booking/presentation/bloc/history/history_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockGetMyBookings extends Mock implements GetMyBookings {}

class MockJoinBooking extends Mock implements JoinBooking {}

class MockCancelBooking extends Mock implements CancelBooking {} // Added

class FakePaymentParticipant extends Fake implements PaymentParticipant {}

void main() {
  late MockGetMyBookings mockGetMyBookings;
  late MockJoinBooking mockJoinBooking;
  late MockCancelBooking mockCancelBooking; // Added
  late MockFirebaseAuth mockFirebaseAuth;

  const tUserId = 'user123';
  const tSplitCode = 'ABCDEF';

  final tBooking = Booking(
    id: '1',
    userId: tUserId,
    venueId: 'v1',
    courtId: 'c1',
    sportType: 'badminton',
    date: DateTime.parse('2023-01-01'),
    startTime: DateTime(2023, 1, 1, 10),
    endTime: DateTime(2023, 1, 1, 11),
    durationHours: 1,
    totalPrice: 100000,
    status: 'confirmed',
    paymentStatus: 'paid',
    isSplitBill: false,
    participants: const [],
    participantIds: const [],
    createdAt: DateTime.parse('2023-01-01'),
  );

  final List<Booking> tBookings = [tBooking];

  setUpAll(() {
    registerFallbackValue(FakePaymentParticipant());
  });

  setUp(() {
    mockGetMyBookings = MockGetMyBookings();
    mockJoinBooking = MockJoinBooking();
    mockCancelBooking = MockCancelBooking(); // Added
    mockFirebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: tUserId, displayName: 'Test User'),
    );
  });

  test('initial state should be HistoryInitial', () {
    final historyBloc = HistoryBloc(
      getMyBookings: mockGetMyBookings,
      joinBooking: mockJoinBooking,
      cancelBooking: mockCancelBooking, // Added
      firebaseAuth: mockFirebaseAuth,
    );
    expect(historyBloc.state, HistoryInitial());
    historyBloc.close();
  });

  blocTest<HistoryBloc, HistoryState>(
    'emits [HistoryLoading, HistoryLoaded] when FetchBookingHistory is added and successful',
    build: () {
      when(
        () => mockGetMyBookings(any()),
      ).thenAnswer((_) async => Right(tBookings));
      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking, // Added
        firebaseAuth: mockFirebaseAuth,
      );
    },
    act: (bloc) => bloc.add(const FetchBookingHistory(tUserId)),
    expect: () => [HistoryLoading(), HistoryLoaded(tBookings)],
    verify: (_) {
      verify(() => mockGetMyBookings(tUserId)).called(1);
    },
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits [HistoryLoading, HistoryLoaded] with cancelled booking when expired waiting_payment is found',
    build: () {
      final expiredBooking = Booking(
        id: 'exp1',
        userId: tUserId,
        venueId: 'v1',
        courtId: 'c1',
        sportType: 'badminton',
        date: DateTime.now(),
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        durationHours: 1,
        totalPrice: 100000,
        status: 'waiting_payment',
        paymentStatus: 'pending',
        createdAt: DateTime.now().subtract(
          const Duration(minutes: 20),
        ), // Expired
      );

      when(
        () => mockGetMyBookings(any()),
      ).thenAnswer((_) async => Right([expiredBooking]));
      when(
        () => mockCancelBooking(any()),
      ).thenAnswer((_) async => const Right(null));

      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking,
        firebaseAuth: mockFirebaseAuth,
      );
    },
    act: (bloc) => bloc.add(const FetchBookingHistory(tUserId)),
    expect: () {
      // Create the expected cancelled booking
      // We need to be careful with DateTime.now() in tests, but here the logic is based on createdAt
      return [
        HistoryLoading(),
        isA<HistoryLoaded>().having(
          (s) => s.bookings.first.status,
          'status',
          'cancelled',
        ),
      ];
    },
    verify: (_) {
      verify(() => mockGetMyBookings(tUserId)).called(1);
      verify(() => mockCancelBooking('exp1')).called(1);
    },
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits [HistoryLoading, HistoryError] when FetchBookingHistory is added and fails',
    build: () {
      when(
        () => mockGetMyBookings(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));
      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking, // Added
        firebaseAuth: mockFirebaseAuth,
      );
    },
    act: (bloc) => bloc.add(const FetchBookingHistory(tUserId)),
    expect: () => [HistoryLoading(), const HistoryError('Server Error')],
    verify: (_) {
      verify(() => mockGetMyBookings(tUserId)).called(1);
    },
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits [HistoryLoading, HistoryJoinSuccess, HistoryLoaded] when JoinBookingRequested is successful',
    build: () {
      when(
        () => mockJoinBooking(any(), any()),
      ).thenAnswer((_) async => const Right('1'));
      when(
        () => mockGetMyBookings(any()),
      ).thenAnswer((_) async => Right(tBookings));
      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking, // Added
        firebaseAuth: mockFirebaseAuth,
      );
    },
    act: (bloc) => bloc.add(const JoinBookingRequested(tSplitCode, tUserId)),
    expect: () => [
      HistoryLoading(),
      const HistoryJoinSuccess('1'),
      HistoryLoading(),
      HistoryLoaded(tBookings),
    ],
    verify: (_) {
      final captured = verify(
        () => mockJoinBooking(captureAny(), captureAny()),
      ).captured;
      expect(captured[0], tSplitCode);
      expect(captured[1].uid, tUserId);
      verify(() => mockGetMyBookings(tUserId)).called(1);
    },
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits [HistoryLoading, HistoryError] when JoinBookingRequested fails',
    build: () {
      when(
        () => mockJoinBooking(any(), any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Join Failed')));
      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        cancelBooking: mockCancelBooking, // Added
        firebaseAuth: mockFirebaseAuth,
      );
    },
    act: (bloc) => bloc.add(const JoinBookingRequested(tSplitCode, tUserId)),
    expect: () => [HistoryLoading(), const HistoryError('Join Failed')],
    verify: (_) {
      final captured = verify(
        () => mockJoinBooking(captureAny(), captureAny()),
      ).captured;
      expect(captured[0], tSplitCode);
      expect(captured[1].uid, tUserId);
      verifyNoMoreInteractions(mockGetMyBookings);
    },
  );
}
