import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../../../../core/error/exceptions.dart';
import '../models/booking_model.dart';
import '../models/payment_participant_model.dart';
import '../../domain/entities/payment_participant.dart';

abstract class BookingRemoteDataSource {
  Future<String> createBooking(BookingModel booking);
  Future<bool> checkAvailability({
    required String courtId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<void> cancelBooking(String bookingId);
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<List<BookingModel>> getMyBookings(String userId);
  Future<void> generateSplitCode(String bookingId);
  Future<String> joinBooking(String splitCode, PaymentParticipant participant);
  Future<BookingModel> getBookingDetail(String bookingId);
  Future<void> updateParticipantStatus(
    String bookingId,
    String participantUid,
    String newStatus,
  );
  Future<void> updatePaymentInfo(
      String bookingId, String paymentUrl, String orderId);
}

@LazySingleton(as: BookingRemoteDataSource)
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> updatePaymentInfo(
      String bookingId, String paymentUrl, String orderId) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'midtransPaymentUrl': paymentUrl,
        'midtransOrderId': orderId,
        'status': 'waiting_payment', // Ensure status is waiting_payment
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update payment info');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BookingModel>> getMyBookings(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('bookings')
          .where('participantIds', arrayContains: userId)
          .get();

      final bookings = querySnapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();

      // Client-side sort by createdAt descending (Newest first)
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return bookings;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch user bookings');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> createBooking(BookingModel booking) async {
    try {
      // Ensure participantIds contains at least the creator
      final json = booking.toJson();
      if ((json['participantIds'] as List?)?.isEmpty ?? true) {
        json['participantIds'] = [booking.userId];
      }

      final docRef = await firestore.collection('bookings').add(json);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create booking');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to cancel booking');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (status == 'paid') {
        data['paymentStatus'] = 'paid';
      }
      await firestore.collection('bookings').doc(bookingId).update(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update booking status');
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
      throw ServerException(e.message ?? 'Firebase Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> generateSplitCode(String bookingId) async {
    try {
      final String splitCode = _generateRandomCode();
      await firestore.collection('bookings').doc(bookingId).update({
        'splitCode': splitCode,
        'isSplitBill': true,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> joinBooking(
    String splitCode,
    PaymentParticipant participant,
  ) async {
    try {
      final cleanCode = splitCode.trim().toUpperCase();
      developer.log(
        'DEBUG JOIN: Searching for code [$cleanCode] in collection bookings',
      );

      final querySnapshot = await firestore
          .collection('bookings')
          .where('splitCode', isEqualTo: cleanCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw ServerException('Booking with this code not found.');
      }

      final bookingDocRef = querySnapshot.docs.first.reference;
      await bookingDocRef.update({
        'participants': FieldValue.arrayUnion([
          PaymentParticipantModel.fromEntity(participant).toJson(),
        ]),
        'participantIds': FieldValue.arrayUnion([participant.uid]),
      });
      return bookingDocRef.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final code = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    return code.toUpperCase();
  }

  @override
  Future<BookingModel> getBookingDetail(String bookingId) async {
    try {
      final docSnapshot = await firestore
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!docSnapshot.exists) {
        throw ServerException('Booking not found.');
      }

      return BookingModel.fromFirestore(docSnapshot);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateParticipantStatus(
    String bookingId,
    String participantUid,
    String newStatus,
  ) async {
    try {
      return firestore.runTransaction((transaction) async {
        final docRef = firestore.collection('bookings').doc(bookingId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw ServerException('Booking not found');
        }

        final bookingData = snapshot.data()!;
        final participants = (bookingData['participants'] as List<dynamic>)
            .map((e) => PaymentParticipantModel.fromJson(e))
            .toList();

        final index = participants.indexWhere((p) => p.uid == participantUid);
        if (index == -1) {
          throw ServerException('Participant not found');
        }

        // Update the participant status
        final updatedParticipant = participants[index].copyWith(
          paymentStatusToHost: newStatus,
        );
        participants[index] = updatedParticipant;

        transaction.update(docRef, {
          'participants': participants.map((e) => e.toJson()).toList(),
        });
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update participant status');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
