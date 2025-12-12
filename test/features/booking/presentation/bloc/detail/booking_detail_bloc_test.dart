import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/generate_split_code.dart';
import 'package:gsports/features/booking/domain/usecases/get_booking_detail.dart';
import 'package:gsports/features/booking/presentation/bloc/detail/booking_detail_bloc.dart';

class MockGetBookingDetail extends Mock implements GetBookingDetail {}

class MockGenerateSplitCode extends Mock implements GenerateSplitCode {}

class FakeBooking extends Fake implements Booking {}

void main() {
  late BookingDetailBloc bookingDetailBloc;
  late MockGetBookingDetail mockGetBookingDetail;
  late MockGenerateSplitCode mockGenerateSplitCode;

  setUpAll(() {
    registerFallbackValue(FakeBooking());
  });

  setUp(() {
    mockGetBookingDetail = MockGetBookingDetail();
    mockGenerateSplitCode = MockGenerateSplitCode();
    bookingDetailBloc = BookingDetailBloc(
      mockGetBookingDetail,
      mockGenerateSplitCode,
    );
  });

  tearDown(() {
    bookingDetailBloc.close();
  });

  const tBookingId = 'testBookingId';
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
        return bookingDetailBloc;
      },
      act: (bloc) => bloc.add(const FetchBookingDetail(tBookingId)),
      expect: () => [BookingDetailLoading(), BookingDetailLoaded(tBooking)],
      verify: (_) {
        verify(() => mockGetBookingDetail(tBookingId)).called(1);
      },
    );

    blocTest<BookingDetailBloc, BookingDetailState>(
      'emits [BookingDetailLoading, BookingDetailError] when FetchBookingDetail fails',
      build: () {
        when(
          () => mockGetBookingDetail(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));
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
      'emits [BookingDetailLoading, BookingDetailError] when GenerateCodeRequested fails',
      build: () {
        when(
          () => mockGenerateSplitCode(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));
        return bookingDetailBloc;
      },
      act: (bloc) => bloc.add(const GenerateCodeRequested(tBookingId)),
      expect: () => [
        BookingDetailLoading(),
        const BookingDetailError('Server Error'),
      ],
      verify: (_) {
        verify(() => mockGenerateSplitCode(tBookingId)).called(1);
        verifyNoMoreInteractions(mockGetBookingDetail); // no refresh on failure
      },
    );
  });
}
