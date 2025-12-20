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

class MockCheckAvailability extends Mock implements CheckAvailability {}

class MockCreateBooking extends Mock implements CreateBooking {}

class MockCreateInvoice extends Mock implements CreateInvoice {}

class MockCancelBooking extends Mock implements CancelBooking {}

class MockUpdateBookingStatus extends Mock implements UpdateBookingStatus {}

class MockGetTransactionStatus extends Mock implements GetTransactionStatus {}

void main() {
  late BookingBloc bookingBloc;
  late MockCheckAvailability mockCheckAvailability;
  late MockCreateBooking mockCreateBooking;
  late MockCreateInvoice mockCreateInvoice;
  late MockCancelBooking mockCancelBooking;
  late MockUpdateBookingStatus mockUpdateBookingStatus;
  late MockGetTransactionStatus mockGetTransactionStatus;

  setUp(() {
    mockCheckAvailability = MockCheckAvailability();
    mockCreateBooking = MockCreateBooking();
    mockCreateInvoice = MockCreateInvoice();
    mockCancelBooking = MockCancelBooking();
    mockUpdateBookingStatus = MockUpdateBookingStatus();
    mockGetTransactionStatus = MockGetTransactionStatus();

    bookingBloc = BookingBloc(
      checkAvailability: mockCheckAvailability,
      createBooking: mockCreateBooking,
      createInvoice: mockCreateInvoice,
      cancelBooking: mockCancelBooking,
      updateBookingStatus: mockUpdateBookingStatus,
      getTransactionStatus: mockGetTransactionStatus,
    );
  });

  final tDate = DateTime(2025, 12, 21);
  final tSlot8 = DateTime(2025, 12, 21, 8);
  final tSlot9 = DateTime(2025, 12, 21, 9);
  final tSlot10 = DateTime(2025, 12, 21, 10);
  final tSlot12 = DateTime(2025, 12, 21, 12);

  group('BookingBloc Multi-Slot Selection', () {
    blocTest<BookingBloc, BookingState>(
      'adds a slot when selectedSlots is empty',
      build: () => bookingBloc,
      seed: () => BookingAvailabilityLoaded(
        availabilityMap: const {8: true, 9: true},
        selectedCourtId: 'court1',
        selectedDate: tDate,
        selectedSlots: const [],
      ),
      act: (bloc) => bloc.add(BookingSlotSelected(tSlot8)),
      expect: () => [
        BookingAvailabilityLoaded(
          availabilityMap: const {8: true, 9: true},
          selectedCourtId: 'court1',
          selectedDate: tDate,
          selectedSlots: [tSlot8],
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'adds consecutive next slot',
      build: () => bookingBloc,
      seed: () => BookingAvailabilityLoaded(
        availabilityMap: const {8: true, 9: true, 10: true},
        selectedCourtId: 'court1',
        selectedDate: tDate,
        selectedSlots: [tSlot8],
      ),
      act: (bloc) => bloc.add(BookingSlotSelected(tSlot9)),
      expect: () => [
        BookingAvailabilityLoaded(
          availabilityMap: const {8: true, 9: true, 10: true},
          selectedCourtId: 'court1',
          selectedDate: tDate,
          selectedSlots: [tSlot8, tSlot9],
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'adds consecutive previous slot',
      build: () => bookingBloc,
      seed: () => BookingAvailabilityLoaded(
        availabilityMap: const {8: true, 9: true, 10: true},
        selectedCourtId: 'court1',
        selectedDate: tDate,
        selectedSlots: [tSlot9],
      ),
      act: (bloc) => bloc.add(BookingSlotSelected(tSlot8)),
      expect: () => [
        BookingAvailabilityLoaded(
          availabilityMap: const {8: true, 9: true, 10: true},
          selectedCourtId: 'court1',
          selectedDate: tDate,
          selectedSlots: [tSlot8, tSlot9],
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'resets selection when adding non-consecutive slot',
      build: () => bookingBloc,
      seed: () => BookingAvailabilityLoaded(
        availabilityMap: const {8: true, 9: true, 12: true},
        selectedCourtId: 'court1',
        selectedDate: tDate,
        selectedSlots: [tSlot8],
      ),
      act: (bloc) => bloc.add(BookingSlotSelected(tSlot12)),
      expect: () => [
        BookingAvailabilityLoaded(
          availabilityMap: const {8: true, 9: true, 12: true},
          selectedCourtId: 'court1',
          selectedDate: tDate,
          selectedSlots: [tSlot12],
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'deselects slot and trims tail',
      build: () => bookingBloc,
      seed: () => BookingAvailabilityLoaded(
        availabilityMap: const {8: true, 9: true, 10: true},
        selectedCourtId: 'court1',
        selectedDate: tDate,
        selectedSlots: [tSlot8, tSlot9, tSlot10],
      ),
      act: (bloc) => bloc.add(BookingSlotSelected(tSlot9)),
      expect: () => [
        BookingAvailabilityLoaded(
          availabilityMap: const {8: true, 9: true, 10: true},
          selectedCourtId: 'court1',
          selectedDate: tDate,
          selectedSlots: [tSlot8],
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'deselects the only slot',
      build: () => bookingBloc,
      seed: () => BookingAvailabilityLoaded(
        availabilityMap: const {8: true},
        selectedCourtId: 'court1',
        selectedDate: tDate,
        selectedSlots: [tSlot8],
      ),
      act: (bloc) => bloc.add(BookingSlotSelected(tSlot8)),
      expect: () => [
        BookingAvailabilityLoaded(
          availabilityMap: const {8: true},
          selectedCourtId: 'court1',
          selectedDate: tDate,
          selectedSlots: const [],
        ),
      ],
    );
  });
}
