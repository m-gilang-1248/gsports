# Implementation Plan: Split Bill Backend Refinement

## Phase 1: Preparation & Entity Updates
- [x] Run all tests to ensure the project is in a good state.
- [x] **Modify Entity:** Update `lib/features/booking/domain/entities/booking.dart` to include `final List<String> participantIds`.
- [x] **Modify Model:** Update `lib/features/booking/data/models/booking_model.dart` to include `participantIds` in properties, `fromJson`, `fromFirestore`, and `toJson`.
- [x] **Run Build Runner:** Execute `dart run build_runner build --delete-conflicting-outputs` in `gsports` directory to regenerate `booking_model.g.dart`.
- [x] **Fix Breaking Changes:** Update all code instantiating `Booking` or `BookingModel` (Repositories, Blocs, Tests) to provide `participantIds`.

## Phase 2: Logic & DataSource Updates
- [ ] **Update Create Logic:** In `BookingRemoteDataSource.createBooking`, ensure `participantIds` is initialized with `[booking.userId]`.
- [ ] **Update Join Logic:** In `BookingRemoteDataSource.joinBooking`, add `participantIds: FieldValue.arrayUnion([participantUid])` to the update call.
- [ ] **Update Query Logic:** In `BookingRemoteDataSource.getMyBookings`, change the query to `.where('participantIds', arrayContains: userId)`.
- [ ] **Implement Status Update (DataSource):** Add `updateParticipantStatus` to `BookingRemoteDataSource` using Read-Modify-Write strategy.

## Phase 3: Repository & UseCase Implementation
- [ ] **Update Repository Interface:** Add `updateParticipantStatus` to `BookingRepository` abstract class.
- [ ] **Update Repository Impl:** Implement `updateParticipantStatus` in `BookingRepositoryImpl`.
- [ ] **Create UseCase:** Create `lib/features/booking/domain/usecases/update_participant_status.dart`.
- [ ] **Register DI:** Register the new UseCase in `lib/injection_container.dart` (if manual) or ensure `@LazySingleton` annotation is present.

## Phase 4: Verification & Cleanup
- [ ] **Fix Static Analysis:** Run `dart_fix` and `analyze_files`.
- [ ] **Unit Tests:** Update existing tests or add new ones for the changed logic (especially the new query construction if mockable, and the status update logic).
- [ ] **Format Code:** Run `dart_format`.
- [ ] **Final Review:** Update `MODIFICATION_IMPLEMENTATION.md` journal.
- [ ] **Commit:** Create a commit with message `feat(booking): add participantIds and update status logic`.

## Post-Implementation
- [ ] **Manual Test:** Verify "My Bookings" shows joined bookings and Host can update status in the app (UI implementation is next, but backend must be ready).
- [ ] Update `GEMINI.md`.

## Journal
- **2025-12-13**: Plan created.
- **2025-12-13**: Phase 1 completed:
    - Ran tests (all passed).
    - Modified `Booking` entity (`booking.dart`) to include `participantIds`.
    - Modified `BookingModel` (`booking_model.dart`) to include `participantIds` in properties, constructor, `fromJson`, `fromFirestore`, and `toJson`.
    - Ran `dart run build_runner build --delete-conflicting-outputs` successfully.
    - Fixed breaking changes in `booking_bottom_sheet.dart` and `booking_repository_impl.dart` by providing `participantIds` to `Booking` and `BookingModel` constructors respectively.
