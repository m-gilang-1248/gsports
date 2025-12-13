import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_core/firebase_core.dart'; // For FirebaseException
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:gsports/features/booking/data/models/booking_model.dart';
import 'package:gsports/features/booking/data/models/payment_participant_model.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/domain/repositories/booking_repository.dart';

@Injectable(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> createBooking(Booking booking) async {
    try {
      final bookingModel = BookingModel(
        id: '', // Firestore will assign an ID, so pass empty string
        userId: booking.userId,
        venueId: booking.venueId,
        courtId: booking.courtId,
        sportType: booking.sportType,
        date: booking.date,
        startTime: booking.startTime,
        endTime: booking.endTime,
        durationHours: booking.durationHours,
        totalPrice: booking.totalPrice,
        status: booking.status,
        paymentStatus: booking.paymentStatus,
        midtransOrderId: booking.midtransOrderId,
        midtransPaymentUrl: booking.midtransPaymentUrl,
        isSplitBill: booking.isSplitBill,
        splitCode: booking.splitCode,
        participants: booking.participants
            .map((e) => PaymentParticipantModel.fromEntity(e))
            .toList(),
        participantIds: booking.participantIds,
      );
      final bookingId = await remoteDataSource.createBooking(bookingModel);
      return Right(bookingId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAvailability({
    required String courtId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final isAvailable = await remoteDataSource.checkAvailability(
        courtId: courtId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(isAvailable);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await remoteDataSource.cancelBooking(bookingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      await remoteDataSource.updateBookingStatus(bookingId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings(String userId) async {
    try {
      final bookingModels = await remoteDataSource.getMyBookings(userId);
      return Right(bookingModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> generateSplitCode(String bookingId) async {
    try {
      await remoteDataSource.generateSplitCode(bookingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> joinBooking(
    String splitCode,
    PaymentParticipant participant,
  ) async {
    try {
      final bookingId = await remoteDataSource.joinBooking(
        splitCode,
        participant,
      );
      return Right(bookingId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingDetail(String bookingId) async {
    try {
      final bookingModel = await remoteDataSource.getBookingDetail(bookingId);
      return Right(bookingModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
