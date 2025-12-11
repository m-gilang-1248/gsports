import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:gsports/features/booking/presentation/bloc/history/history_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyBookings extends Mock implements GetMyBookings {}

void main() {
  late HistoryBloc historyBloc;
  late MockGetMyBookings mockGetMyBookings;

  setUp(() {
    mockGetMyBookings = MockGetMyBookings();
    historyBloc = HistoryBloc(getMyBookings: mockGetMyBookings);
  });

  tearDown(() {
    historyBloc.close();
  });

  const tUserId = 'user123';
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
    )
  ];

  test('initial state should be HistoryInitial', () {
    expect(historyBloc.state, HistoryInitial());
  });

  test('emits [HistoryLoading, HistoryLoaded] when FetchBookingHistory is added and successful', () async {
    // arrange
    when(() => mockGetMyBookings(any()))
        .thenAnswer((_) async => Right(tBookings));
    
    // assert later
    final expectedStates = [
      HistoryLoading(),
      HistoryLoaded(tBookings),
    ];
    expectLater(historyBloc.stream, emitsInOrder(expectedStates));

    // act
    historyBloc.add(const FetchBookingHistory(tUserId));
  });

  test('emits [HistoryLoading, HistoryError] when FetchBookingHistory is added and fails', () async {
    // arrange
    when(() => mockGetMyBookings(any()))
        .thenAnswer((_) async => const Left(ServerFailure('Server Error')));

    // assert later
    final expectedStates = [
      HistoryLoading(),
      const HistoryError('Server Error'),
    ];
    expectLater(historyBloc.stream, emitsInOrder(expectedStates));

    // act
    historyBloc.add(const FetchBookingHistory(tUserId));
  });
}