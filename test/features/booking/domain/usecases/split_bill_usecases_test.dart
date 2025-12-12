import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/domain/repositories/booking_repository.dart';
import 'package:gsports/features/booking/domain/usecases/generate_split_code.dart';
import 'package:gsports/features/booking/domain/usecases/join_booking.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

class FakePaymentParticipant extends Fake implements PaymentParticipant {}

void main() {
  late GenerateSplitCode generateSplitCodeUsecase;
  late JoinBooking joinBookingUsecase;
  late MockBookingRepository mockBookingRepository;

  setUpAll(() {
    registerFallbackValue(FakePaymentParticipant());
  });

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    generateSplitCodeUsecase = GenerateSplitCode(mockBookingRepository);
    joinBookingUsecase = JoinBooking(mockBookingRepository);
  });

  const tBookingId = '123';
  const tSplitCode = 'ABCDEF';
  const tParticipant = PaymentParticipant(
    uid: 'user1',
    name: 'Test User',
    status: 'joined',
    paymentStatusToHost: 'pending',
  );

  group('GenerateSplitCode', () {
    test('should call generateSplitCode on the repository', () async {
      // arrange
      when(
        () => mockBookingRepository.generateSplitCode(any()),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await generateSplitCodeUsecase(tBookingId);

      // assert
      expect(result, const Right(null));
      verify(
        () => mockBookingRepository.generateSplitCode(tBookingId),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    test('should return ServerFailure when generateSplitCode fails', () async {
      // arrange
      when(
        () => mockBookingRepository.generateSplitCode(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));

      // act
      final result = await generateSplitCodeUsecase(tBookingId);

      // assert
      expect(result, const Left(ServerFailure('Server Error')));
      verify(
        () => mockBookingRepository.generateSplitCode(tBookingId),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });
  });

  group('JoinBooking', () {
    test('should call joinBooking on the repository', () async {
      // arrange
      when(
        () => mockBookingRepository.joinBooking(any(), any()),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await joinBookingUsecase(tSplitCode, tParticipant);

      // assert
      expect(result, const Right(null));
      verify(
        () => mockBookingRepository.joinBooking(tSplitCode, tParticipant),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    test('should return ServerFailure when joinBooking fails', () async {
      // arrange
      when(
        () => mockBookingRepository.joinBooking(any(), any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));

      // act
      final result = await joinBookingUsecase(tSplitCode, tParticipant);

      // assert
      expect(result, const Left(ServerFailure('Server Error')));
      verify(
        () => mockBookingRepository.joinBooking(tSplitCode, tParticipant),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });
  });
}
