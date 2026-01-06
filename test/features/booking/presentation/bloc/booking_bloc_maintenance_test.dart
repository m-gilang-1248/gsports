import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/check_availability.dart';
import 'package:gsports/features/booking/domain/usecases/create_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/booking/domain/usecases/update_booking_status.dart';
import 'package:gsports/features/booking/domain/usecases/update_payment_info.dart';
import 'package:gsports/features/payment/domain/usecases/create_invoice.dart';
import 'package:gsports/features/payment/domain/usecases/get_transaction_status.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:gsports/features/booking/domain/usecases/get_booking_detail.dart';
import 'package:gsports/features/wallet/domain/usecases/create_transaction.dart';

class MockCheckAvailability extends Mock implements CheckAvailability {}

class MockCreateBooking extends Mock implements CreateBooking {}

class MockCreateInvoice extends Mock implements CreateInvoice {}

class MockCancelBooking extends Mock implements CancelBooking {}

class MockUpdateBookingStatus extends Mock implements UpdateBookingStatus {}

class MockGetTransactionStatus extends Mock implements GetTransactionStatus {}

class MockUpdatePaymentInfo extends Mock implements UpdatePaymentInfo {}

class MockGetBookingDetail extends Mock implements GetBookingDetail {}

class MockCreateTransaction extends Mock implements CreateTransaction {}

class FakeCreateBookingParams extends Fake implements CreateBookingParams {}

class FakeUpdateBookingStatusParams extends Fake
    implements UpdateBookingStatusParams {}

class FakeCreateInvoiceParams extends Fake implements CreateInvoiceParams {}

void main() {
  late BookingBloc bookingBloc;
  late MockCheckAvailability mockCheckAvailability;
  late MockCreateBooking mockCreateBooking;
  late MockCreateInvoice mockCreateInvoice;
  late MockCancelBooking mockCancelBooking;
  late MockUpdateBookingStatus mockUpdateBookingStatus;
  late MockGetTransactionStatus mockGetTransactionStatus;
  late MockUpdatePaymentInfo mockUpdatePaymentInfo;
  late MockGetBookingDetail mockGetBookingDetail;
  late MockCreateTransaction mockCreateTransaction;

  setUpAll(() {
    registerFallbackValue(FakeCreateBookingParams());
    registerFallbackValue(FakeUpdateBookingStatusParams());
    registerFallbackValue(FakeCreateInvoiceParams());
  });

  setUp(() {
    mockCheckAvailability = MockCheckAvailability();
    mockCreateBooking = MockCreateBooking();
    mockCreateInvoice = MockCreateInvoice();
    mockCancelBooking = MockCancelBooking();
    mockUpdateBookingStatus = MockUpdateBookingStatus();
    mockGetTransactionStatus = MockGetTransactionStatus();
    mockUpdatePaymentInfo = MockUpdatePaymentInfo();
    mockGetBookingDetail = MockGetBookingDetail();
    mockCreateTransaction = MockCreateTransaction();

    when(() => mockGetBookingDetail(any())).thenAnswer(
      (_) async => Left(ServerFailure('not found in test')),
    );

    bookingBloc = BookingBloc(
      checkAvailability: mockCheckAvailability,
      createBooking: mockCreateBooking,
      createInvoice: mockCreateInvoice,
      cancelBooking: mockCancelBooking,
      updateBookingStatus: mockUpdateBookingStatus,
      getTransactionStatus: mockGetTransactionStatus,
      updatePaymentInfo: mockUpdatePaymentInfo,
      getBookingDetail: mockGetBookingDetail,
      createTransaction: mockCreateTransaction,
    );
  });

  final tBooking = Booking(
    id: '1',
    userId: 'user1',
    venueId: 'venue1',
    courtId: 'court1',
    sportType: 'badminton',
    date: DateTime(2025, 12, 21),
    startTime: DateTime(2025, 12, 21, 8),
    endTime: DateTime(2025, 12, 21, 9),
    durationHours: 1,
    totalPrice: 0,
    status: 'maintenance',
    paymentStatus: 'paid',
    createdAt: DateTime.now(),
  );

  group('BookingBloc Maintenance Flow', () {
    blocTest<BookingBloc, BookingState>(
      'skips payment flow and emits BookingPaidSuccess for maintenance bookings',
      build: () {
        when(
          () => mockCreateBooking(any()),
        ).thenAnswer((_) async => const Right('booking_id'));
        when(
          () => mockUpdateBookingStatus(any()),
        ).thenAnswer((_) async => const Right(null));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(BookingCreated(tBooking)),
      expect: () => [BookingLoading(), BookingPaidSuccess('booking_id')],
      verify: (_) {
        verify(() => mockCreateBooking(any())).called(1);
        verify(() => mockUpdateBookingStatus(any())).called(1);
        verifyNever(() => mockCreateInvoice(any()));
      },
    );

    blocTest<BookingBloc, BookingState>(
      'skips payment flow and emits BookingPaidSuccess for pre-paid bookings (totalPrice 0)',
      build: () {
        when(
          () => mockCreateBooking(any()),
        ).thenAnswer((_) async => const Right('booking_id'));
        when(
          () => mockUpdateBookingStatus(any()),
        ).thenAnswer((_) async => const Right(null));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(
        BookingCreated(tBooking.copyWith(totalPrice: 0, status: 'confirmed')),
      ),
      expect: () => [BookingLoading(), BookingPaidSuccess('booking_id')],
      verify: (_) {
        verify(() => mockCreateBooking(any())).called(1);
        verifyNever(() => mockCreateInvoice(any()));
      },
    );
  });
}
