import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsports/features/booking/domain/usecases/check_availability.dart';
import 'package:gsports/features/booking/domain/usecases/create_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/booking/domain/usecases/update_booking_status.dart';
import 'package:gsports/features/payment/domain/usecases/create_invoice.dart';
import 'package:gsports/features/payment/domain/usecases/get_transaction_status.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:gsports/features/booking/domain/usecases/update_payment_info.dart';
import 'package:gsports/features/venue/domain/entities/venue_holiday.dart';
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

class FakeCheckAvailabilityParams extends Fake
    implements CheckAvailabilityParams {}

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
    registerFallbackValue(FakeCheckAvailabilityParams());
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

  final tDate = DateTime(2026, 1, 5);
  final tCourtId = 'court1';

  group('BookingBloc Availability - Holidays & Maintenance', () {
    blocTest<BookingBloc, BookingState>(
      'emits empty availability when date is within a VenueHoliday object range (No Firebase Call)',
      build: () => bookingBloc,
      act: (bloc) => bloc.add(
        BookingAvailabilityChecked(
          courtId: tCourtId,
          date: tDate,
          operatingHours: {
            'holidays': [
              VenueHoliday(
                id: 'h1',
                name: 'Holiday',
                startDate: DateTime(2026, 1, 5),
                endDate: DateTime(2026, 1, 6),
              ),
            ],
          },
        ),
      ),
      expect: () => [
        BookingLoading(),
        isA<BookingAvailabilityLoaded>().having(
          (s) => s.availabilityMap,
          'availabilityMap',
          isEmpty,
        ),
      ],
      verify: (_) {
        verifyNever(() => mockCheckAvailability(any()));
      },
    );
  });
}
