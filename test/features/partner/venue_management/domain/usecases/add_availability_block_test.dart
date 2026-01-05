import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/add_availability_block.dart';
import 'package:gsports/features/partner/venue_management/domain/repositories/venue_management_repository.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:fpdart/fpdart.dart';

class MockVenueManagementRepository extends Mock
    implements VenueManagementRepository {}

class FakeBooking extends Fake implements Booking {}

void main() {
  late AddAvailabilityBlock usecase;
  late MockVenueManagementRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeBooking());
  });

  setUp(() {
    mockRepository = MockVenueManagementRepository();
    usecase = AddAvailabilityBlock(mockRepository);
  });

  final tDate = DateTime(2026, 1, 5, 15, 30); // 3:30 PM
  final tCourt = Court(
    id: 'court1',
    name: 'Court 1',
    sportType: 'Badminton',
    hourlyPrice: 50000,
    photos: const [],
  );

  test(
    'should normalize date to midnight when adding maintenance booking',
    () async {
      // arrange
      when(
        () => mockRepository.addMaintenanceBooking(any()),
      ).thenAnswer((_) async => const Right(null));

      // act
      await usecase(
        AddAvailabilityBlockParams(
          venueId: 'v1',
          venueName: 'Venue 1',
          court: tCourt,
          date: tDate,
        ),
      );

      // assert
      final capturedBooking =
          verify(
                () => mockRepository.addMaintenanceBooking(captureAny()),
              ).captured.first
              as Booking;

      expect(capturedBooking.date.hour, 0);
      expect(capturedBooking.date.minute, 0);
      expect(capturedBooking.date.second, 0);
      expect(capturedBooking.date.year, 2026);
      expect(capturedBooking.date.month, 1);
      expect(capturedBooking.date.day, 5);
    },
  );
}
