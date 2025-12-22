import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/generate_split_code.dart';
import 'package:gsports/features/booking/domain/usecases/get_booking_detail.dart';
import 'package:gsports/features/booking/domain/usecases/update_participant_status.dart'; // New import
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/payment/domain/usecases/get_transaction_status.dart';
import 'package:gsports/features/booking/domain/usecases/update_booking_status.dart';
import 'package:gsports/features/booking/presentation/bloc/detail/booking_detail_bloc.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';

class MockGetBookingDetail extends Mock implements GetBookingDetail {}

class MockGenerateSplitCode extends Mock implements GenerateSplitCode {}

class MockCancelBooking extends Mock implements CancelBooking {}

class MockUpdateParticipantStatus extends Mock
    implements UpdateParticipantStatus {} // New Mock

class MockGetTransactionStatus extends Mock implements GetTransactionStatus {}

class MockUpdateBookingStatus extends Mock implements UpdateBookingStatus {}

class MockScoreboardRepository extends Mock implements ScoreboardRepository {}

class FakeBooking extends Fake implements Booking {}

void main() {
  late BookingDetailBloc bookingDetailBloc;
  late MockGetBookingDetail mockGetBookingDetail;
  late MockGenerateSplitCode mockGenerateSplitCode;
  late MockUpdateParticipantStatus mockUpdateParticipantStatus;
  late MockCancelBooking mockCancelBooking;
  late MockGetTransactionStatus mockGetTransactionStatus;
  late MockUpdateBookingStatus mockUpdateBookingStatus;
  late MockScoreboardRepository mockScoreboardRepository;

  setUpAll(() {
    registerFallbackValue(FakeBooking());
    registerFallbackValue(MockUpdateParticipantStatus());
  });

  setUp(() {
    mockGetBookingDetail = MockGetBookingDetail();
    mockGenerateSplitCode = MockGenerateSplitCode();
    mockUpdateParticipantStatus = MockUpdateParticipantStatus();
    mockCancelBooking = MockCancelBooking();
    mockGetTransactionStatus = MockGetTransactionStatus();
    mockUpdateBookingStatus = MockUpdateBookingStatus();
    mockScoreboardRepository = MockScoreboardRepository();

    bookingDetailBloc = BookingDetailBloc(
      mockGetBookingDetail,
      mockGenerateSplitCode,
      mockUpdateParticipantStatus,
      mockCancelBooking,
      mockGetTransactionStatus,
      mockUpdateBookingStatus,
      mockScoreboardRepository,
    );
  });

  tearDown(() {
    bookingDetailBloc.close();
  });

  const tBookingId = 'testBookingId';
  const tParticipantUid = 'participant123';
  const tNewStatus = 'paid';
  final tBooking = Booking(
    id: tBookingId,
    userId: 'user123',
    venueId: 'venue123',
    courtId: 'court123',
    sportType: 'Badminton',
    date: DateTime.now(),
    startTime: DateTime.now().add(const Duration(hours: 1)),
    endTime: DateTime.now().add(const Duration(hours: 2)),
    durationHours: 1,
    totalPrice: 100000,
    status: 'confirmed',
    paymentStatus: 'paid',
    participantIds: ['user123'], // New field
    createdAt: DateTime.now().subtract(const Duration(days: 1)), // New field
  );

  group('BookingDetailBloc', () {
    test('initial state should be BookingDetailInitial', () {
      expect(bookingDetailBloc.state, BookingDetailInitial());
    });

    blocTest<BookingDetailBloc, BookingDetailState>(
      'emits [BookingDetailLoading, BookingDetailLoaded] when FetchBookingDetail is successful',
      build: () {
        when(
          () => mockGetBookingDetail(any()),
        ).thenAnswer((_) async => Right(tBooking));
        when(
          () => mockScoreboardRepository.getMatchesByBooking(any()),
        ).thenAnswer((_) async => const Right([]));
        return bookingDetailBloc;
      },
      act: (bloc) => bloc.add(const FetchBookingDetail(tBookingId)),
      expect: () => [BookingDetailLoading(), BookingDetailLoaded(tBooking)],
      verify: (_) {
        verify(() => mockGetBookingDetail(tBookingId)).called(1);
        verify(
          () => mockScoreboardRepository.getMatchesByBooking(tBookingId),
        ).called(1);
      },
    );

    blocTest<BookingDetailBloc, BookingDetailState>(
      'emits [BookingDetailLoading, BookingDetailError] when FetchBookingDetail fails',
      build: () {
        when(
          () => mockGetBookingDetail(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));
        when(
          () => mockScoreboardRepository.getMatchesByBooking(any()),
        ).thenAnswer((_) async => const Right([]));
        return bookingDetailBloc;
      },
      act: (bloc) => bloc.add(const FetchBookingDetail(tBookingId)),
      expect: () => [
        BookingDetailLoading(),
        const BookingDetailError('Server Error'),
      ],
      verify: (_) {
        verify(() => mockGetBookingDetail(tBookingId)).called(1);
      },
    );

    blocTest<BookingDetailBloc, BookingDetailState>(
      'emits [BookingDetailLoading, BookingDetailLoaded] when GenerateCodeRequested is successful',
      build: () {
        when(
          () => mockGenerateSplitCode(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockGetBookingDetail(any()),
        ).thenAnswer((_) async => Right(tBooking)); // for refresh
        when(
          () => mockScoreboardRepository.getMatchesByBooking(any()),
        ).thenAnswer((_) async => const Right([]));
        return bookingDetailBloc;
      },
      act: (bloc) => bloc.add(const GenerateCodeRequested(tBookingId)),
      expect: () => [BookingDetailLoading(), BookingDetailLoaded(tBooking)],
      verify: (_) {
        verify(() => mockGenerateSplitCode(tBookingId)).called(1);
        verify(
          () => mockGetBookingDetail(tBookingId),
        ).called(1); // after refresh
      },
    );

    blocTest<BookingDetailBloc, BookingDetailState>(
      'emits [BookingDetailLoading (with isUpdatingParticipant: true), BookingDetailLoaded] when UpdateParticipantPaymentStatus is successful',
      build: () {
        when(
          () => mockUpdateParticipantStatus(
            bookingId: any(named: 'bookingId'),
            participantUid: any(named: 'participantUid'),
            newStatus: any(named: 'newStatus'),
          ),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockGetBookingDetail(any()),
        ).thenAnswer((_) async => Right(tBooking)); // for refresh
        when(
          () => mockScoreboardRepository.getMatchesByBooking(any()),
        ).thenAnswer((_) async => const Right([]));
        return bookingDetailBloc;
      },
      seed: () => BookingDetailLoaded(tBooking), // Start with a loaded state
      act: (bloc) => bloc.add(
        const UpdateParticipantPaymentStatus(
          bookingId: tBookingId,
          participantUid: tParticipantUid,
          newStatus: tNewStatus,
        ),
      ),
      expect: () => [
        BookingDetailLoaded(tBooking, isUpdatingParticipant: true),
        BookingDetailLoading(),
        BookingDetailLoaded(tBooking),
      ],
      verify: (_) {
        verify(
          () => mockUpdateParticipantStatus(
            bookingId: tBookingId,
            participantUid: tParticipantUid,
            newStatus: tNewStatus,
          ),
        ).called(1);
        verify(() => mockGetBookingDetail(tBookingId)).called(1);
      },
    );

    blocTest<BookingDetailBloc, BookingDetailState>(
      'emits [BookingDetailLoading, BookingDetailLoaded] when CancelBookingRequested is successful',
      build: () {
        when(
          () => mockCancelBooking(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockGetBookingDetail(any()),
        ).thenAnswer((_) async => Right(tBooking)); // for refresh
        when(
          () => mockScoreboardRepository.getMatchesByBooking(any()),
        ).thenAnswer((_) async => const Right([]));
        return bookingDetailBloc;
      },
      act: (bloc) => bloc.add(const CancelBookingRequested(tBookingId)),
      expect: () => [BookingDetailLoading(), BookingDetailLoaded(tBooking)],
      verify: (_) {
        verify(() => mockCancelBooking(tBookingId)).called(1);
        verify(
          () => mockGetBookingDetail(tBookingId),
        ).called(1); // after refresh
      },
    );

    blocTest<BookingDetailBloc, BookingDetailState>(
      'emits [BookingDetailLoading (with isUpdatingParticipant: true), BookingDetailError] when UpdateParticipantPaymentStatus fails',
      build: () {
        when(
          () => mockUpdateParticipantStatus(
            bookingId: any(named: 'bookingId'),
            participantUid: any(named: 'participantUid'),
            newStatus: any(named: 'newStatus'),
          ),
        ).thenAnswer((_) async => const Left(ServerFailure('Update Failed')));
        return bookingDetailBloc;
      },
      seed: () => BookingDetailLoaded(tBooking), // Start with a loaded state
      act: (bloc) => bloc.add(
        const UpdateParticipantPaymentStatus(
          bookingId: tBookingId,
          participantUid: tParticipantUid,
          newStatus: tNewStatus,
        ),
      ),
      expect: () => [
        BookingDetailLoaded(tBooking, isUpdatingParticipant: true),
        const BookingDetailError('Update Failed'),
      ],
      verify: (_) {
        verify(
          () => mockUpdateParticipantStatus(
            bookingId: tBookingId,
            participantUid: tParticipantUid,
            newStatus: tNewStatus,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockGetBookingDetail); // no refresh on failure
      },
    );
  });
}
