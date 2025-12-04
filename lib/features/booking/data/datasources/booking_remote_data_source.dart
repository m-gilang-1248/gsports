import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/booking_model.dart';
import 'package:gsports/core/error/exceptions.dart';

abstract class BookingRemoteDataSource {
  Future<String> createBooking(BookingModel booking);
  Future<bool> checkAvailability({
    required String courtId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  });
}

@LazySingleton(as: BookingRemoteDataSource)
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl(this.firestore);

  @override
  Future<String> createBooking(BookingModel booking) async {
    try {
      final docRef = await firestore
          .collection('bookings')
          .add(booking.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create booking');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> checkAvailability({
    required String courtId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Normalize date to YYYY-MM-DD for querying
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Fetch bookings for the specific court on the given date
      final querySnapshot = await firestore
          .collection('bookings')
          .where('courtId', isEqualTo: courtId)
          .where(
            'date',
            isEqualTo: Timestamp.fromDate(normalizedDate),
          ) // Query by the normalized date
          .where('status', isNotEqualTo: 'cancelled')
          .get();

      // Check for overlap in fetched bookings
      final conflictingBookings = querySnapshot.docs.where((doc) {
        final existingStartTime = (doc['startTime'] as Timestamp).toDate();
        final existingEndTime = (doc['endTime'] as Timestamp).toDate();

        // Check for overlap: [start, end)
        final overlap =
            (startTime.isBefore(existingEndTime) &&
            endTime.isAfter(existingStartTime));
        return overlap;
      }).toList();

      return conflictingBookings
          .isEmpty; // True if no conflicts, false otherwise
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to check availability');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
