import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:gsports/features/booking/domain/usecases/join_booking.dart';
import 'package:gsports/features/booking/presentation/bloc/history/history_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockGetMyBookings extends Mock implements GetMyBookings {}

class MockJoinBooking extends Mock implements JoinBooking {}

class FakePaymentParticipant extends Fake implements PaymentParticipant {}

void main() {
  late MockGetMyBookings mockGetMyBookings;
  late MockJoinBooking mockJoinBooking;
  late MockFirebaseAuth mockFirebaseAuth;

  const tUserId = 'user123';
  const tSplitCode = 'ABCDEF';

  final tBookings = [
    Booking(
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
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakePaymentParticipant());
  });

  setUp(() {
    mockGetMyBookings = MockGetMyBookings();
    mockJoinBooking = MockJoinBooking();
    mockFirebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: tUserId, displayName: 'Test User'),
    ); // Initialize with a signed-in user
  });

  tearDown(() {
    // No need to close bloc here, it's created per blocTest.
    // For regular tests, if bloc is initialized there, it needs to be closed.
  });

  test('initial state should be HistoryInitial', () {
    final historyBloc = HistoryBloc(
      getMyBookings: mockGetMyBookings,
      joinBooking: mockJoinBooking,
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
    'emits [HistoryLoading, HistoryError] when FetchBookingHistory is added and fails',
    build: () {
      when(
        () => mockGetMyBookings(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));
      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
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
    'emits [HistoryLoading, HistoryLoaded] when JoinBookingRequested is successful',
    build: () {
      when(
        () => mockJoinBooking(any(), any()),
      ).thenAnswer((_) async => const Right('1')); // Return bookingId '1'
      when(
        () => mockGetMyBookings(any()),
      ).thenAnswer((_) async => Right(tBookings));
      return HistoryBloc(
        getMyBookings: mockGetMyBookings,
        joinBooking: mockJoinBooking,
        firebaseAuth: mockFirebaseAuth,
      );
    },
    act: (bloc) => bloc.add(const JoinBookingRequested(tSplitCode, tUserId)),
    expect: () => [HistoryLoading(), HistoryLoaded(tBookings)],
    verify: (_) {
      final captured = verify(
        () => mockJoinBooking(captureAny(), captureAny()),
      ).captured;
      expect(captured[0], tSplitCode);
      expect(captured[1].uid, tUserId);
      verify(() => mockGetMyBookings(tUserId)).called(1);
      verify(() => mockFirebaseAuth.currentUser).called(1);
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
      verify(() => mockFirebaseAuth.currentUser).called(1);
    },
  );
}
