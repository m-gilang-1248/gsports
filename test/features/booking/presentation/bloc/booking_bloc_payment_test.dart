import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/usecases/check_availability.dart';
import 'package:gsports/features/booking/domain/usecases/create_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/booking/domain/usecases/update_booking_status.dart';
import 'package:gsports/features/payment/domain/usecases/create_invoice.dart';
import 'package:gsports/features/payment/domain/usecases/get_transaction_status.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:gsports/features/booking/domain/usecases/update_payment_info.dart';
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

class FakeUpdateBookingStatusParams extends Fake
    implements UpdateBookingStatusParams {}

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
    registerFallbackValue(FakeUpdateBookingStatusParams());
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

  const tBookingId = 'testBookingId';

  group('BookingBloc Payment Completion', () {
    // Scenario 1: Payment Success (Direct from WebView)
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingPaidSuccess] when status is success',
      build: () {
        when(
          () => mockUpdateBookingStatus(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockGetBookingDetail(any()),
        ).thenAnswer((_) async => Left(ServerFailure('test')));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(
        const BookingPaymentCompleted(bookingId: tBookingId, status: 'success'),
      ),
      expect: () => [BookingLoading(), const BookingPaidSuccess(tBookingId)],
      verify: (_) {
        verify(
          () => mockUpdateBookingStatus(
            any(
              that: isA<UpdateBookingStatusParams>().having(
                (p) => p.status,
                'status',
                'paid',
              ),
            ),
          ),
        ).called(1);
      },
    );

    // Scenario 2: Payment Pending (Back from WebView, status != success, Midtrans returns pending)
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingWaitingForPayment] when status is not success and Midtrans returns pending',
      build: () {
        when(
          () => mockGetTransactionStatus(tBookingId),
        ).thenAnswer((_) async => const Right('pending'));
        when(
          () => mockUpdateBookingStatus(any()),
        ).thenAnswer((_) async => const Right(null));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(
        const BookingPaymentCompleted(
          bookingId: tBookingId,
          status: 'pending', // or anything else
        ),
      ),
      expect: () => [
        BookingLoading(),
        const BookingWaitingForPayment(tBookingId),
      ],
      verify: (_) {
        verify(() => mockGetTransactionStatus(tBookingId)).called(1);
        verify(
          () => mockUpdateBookingStatus(
            any(
              that: isA<UpdateBookingStatusParams>().having(
                (p) => p.status,
                'status',
                'waiting_payment',
              ),
            ),
          ),
        ).called(1);
      },
    );

    // Scenario 3: Payment Not Found (Back from WebView, Midtrans returns not_found)
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingWaitingForPayment] when status is not success and Midtrans returns not_found',
      build: () {
        when(
          () => mockGetTransactionStatus(tBookingId),
        ).thenAnswer((_) async => const Right('not_found'));
        when(
          () => mockUpdateBookingStatus(any()),
        ).thenAnswer((_) async => const Right(null));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(
        const BookingPaymentCompleted(
          bookingId: tBookingId,
          status: 'back_button',
        ),
      ),
      expect: () => [
        BookingLoading(),
        const BookingWaitingForPayment(tBookingId),
      ],
      verify: (_) {
        verify(() => mockGetTransactionStatus(tBookingId)).called(1);
        verify(
          () => mockUpdateBookingStatus(
            any(
              that: isA<UpdateBookingStatusParams>().having(
                (p) => p.status,
                'status',
                'waiting_payment',
              ),
            ),
          ),
        ).called(1);
      },
    );

    // Scenario 4: Payment Expired/Cancelled (Midtrans returns expire)
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingCancelledState] when Midtrans returns expire',
      build: () {
        when(
          () => mockGetTransactionStatus(tBookingId),
        ).thenAnswer((_) async => const Right('expire'));
        when(
          () => mockCancelBooking(tBookingId),
        ).thenAnswer((_) async => const Right(null));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(
        const BookingPaymentCompleted(bookingId: tBookingId, status: 'other'),
      ),
      expect: () => [BookingLoading(), const BookingCancelledState(tBookingId)],
      verify: (_) {
        verify(() => mockGetTransactionStatus(tBookingId)).called(1);
        verify(() => mockCancelBooking(tBookingId)).called(1);
      },
    );
  });
}
