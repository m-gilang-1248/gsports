import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/repositories/booking_repository.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late GetMyBookings usecase;
  late MockBookingRepository mockBookingRepository;

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    usecase = GetMyBookings(mockBookingRepository);
  });

  const tUserId = 'user123';
  final List<Booking> tBookings = [
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

  test('should get list of bookings from the repository', () async {
    // arrange
    when(
      () => mockBookingRepository.getMyBookings(any()),
    ).thenAnswer((_) async => Right(tBookings));
    // act
    final result = await usecase(tUserId);
    // assert
    expect(result, Right(tBookings));
    verify(() => mockBookingRepository.getMyBookings(tUserId));
    verifyNoMoreInteractions(mockBookingRepository);
  });
}
