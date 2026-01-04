import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue_holiday.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';

abstract class VenueManagementRepository {
  Future<Either<Failure, List<Venue>>> getMyVenues(String ownerId);
  Future<Either<Failure, void>> createVenue(Venue venue, List<File> images);
  Future<Either<Failure, void>> updateVenue(
    Venue venue, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  });
  Future<Either<Failure, void>> deleteVenue(String venueId);

  // Court Management
  Future<Either<Failure, List<Court>>> getVenueCourts(String venueId);
  Future<Either<Failure, void>> addCourt(
    String venueId,
    Court court,
    List<File> images,
  );
  Future<Either<Failure, void>> updateCourt(
    String venueId,
    Court court, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  });
  Future<Either<Failure, void>> deleteCourt(String venueId, String courtId);

  // Availability Management
  Future<Either<Failure, bool>> checkBookingConflicts(
    String venueId,
    DateTime startDate,
    DateTime endDate, {
    String? courtId,
  });

  Future<Either<Failure, bool>> checkWeeklyConflict(
    String venueId,
    int dayOfWeek,
  );

  Future<Either<Failure, List<Booking>>> getMaintenanceBookings(
    String venueId,
    DateTime startDate,
    DateTime endDate,
  );

  Future<Either<Failure, void>> addVenueHoliday(
    String venueId,
    VenueHoliday holiday,
  );
  Future<Either<Failure, void>> addMaintenanceBooking(Booking booking);

  Future<Either<Failure, void>> removeVenueHoliday(
    String venueId,
    VenueHoliday holiday,
  );
  Future<Either<Failure, void>> removeMaintenanceBooking(String bookingId);
}
