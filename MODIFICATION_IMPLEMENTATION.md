# MODIFICATION IMPLEMENTATION PLAN: Split Bill Feature (Phase 1)

This plan covers the Domain and Data layer updates required for the Split Bill feature.

## Phase 1: Entity & Model Refactoring
**Goal:** Replace the loose `List<Map>` participants with a strongly typed `PaymentParticipant` entity.

- [x] Run all tests to ensure the project is in a good state before starting modifications.
- [x] Create `lib/features/booking/domain/entities/payment_participant.dart`.
- [x] Create `lib/features/booking/data/models/payment_participant_model.dart` with `fromJson`/`toJson`.
- [x] Update `lib/features/booking/domain/entities/booking.dart`:
    - Change `participants` type to `List<PaymentParticipant>`.
- [x] Update `lib/features/booking/data/models/booking_model.dart`:
    - Update constructor and `fromJson`/`toJson` to handle `PaymentParticipantModel`.
- [x] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate JSON serialization code.
- [x] Fix any compilation errors in the project resulting from these breaking changes.
- [x] Run `dart_fix` to clean up the code.
- [x] Run `analyze_files` to ensure no new issues.
- [x] Run `dart_format` to ensure consistent formatting.
- [ ] Use `git diff` to verify changes and commit with message "refactor: introduce PaymentParticipant entity".
- [ ] Wait for approval.

## Phase 2: Logic Implementation (UseCases & Repository)
**Goal:** Implement the logic for generating split codes and joining bookings.

- [ ] Create `lib/features/booking/domain/usecases/generate_split_code.dart`.
- [ ] Create `lib/features/booking/domain/usecases/join_booking.dart`.
- [ ] Update `lib/features/booking/domain/repositories/booking_repository.dart`:
    - Add `Future<Either<Failure, void>> generateSplitCode(String bookingId);`
    - Add `Future<Either<Failure, void>> joinBooking(String splitCode, PaymentParticipant participant);`
- [ ] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`:
    - Implement `generateSplitCode` (generate random 6-char alphanumeric code & update Firestore).
    - Implement `joinBooking` (query by code, arrayUnion participant).
- [ ] Update `lib/features/booking/data/repositories/booking_repository_impl.dart`:
    - Implement the new repository methods.
- [ ] Create unit tests for `PaymentParticipantModel` and the new UseCases.
- [ ] Run `dart_fix`.
- [ ] Run `analyze_files`.
- [ ] Run `dart_format`.
- [ ] Run all tests to make sure everything passes.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` Journal.
- [ ] Use `git diff` to verify changes and commit with message "feat: add split code generation and join logic".
- [ ] Wait for approval.

## Phase 3: Finalize & Documentation
**Goal:** Ensure clean code and up-to-date documentation.

- [ ] Run full test suite.
- [ ] Update `GEMINI.md` context.
- [ ] Ask user to review the changes.

## Journal
*   Phase 1: Successfully refactored Booking entity to use PaymentParticipant. Updated BookingModel and BookingBottomSheet to handle the new structure. All tests passed.