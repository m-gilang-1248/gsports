# Implementation Plan: Booking History Backend

## Journal
- **Iteration 2 Start:** Starting implementation of backend logic for fetching user booking history.
- **Phase 1 Completed:** Implemented `GetMyBookings` use case, updated `BookingRepository` and `BookingRemoteDataSource` with Firestore query logic (filtering by `userId` and sorting by `startTime`). Registered dependencies with `injectable`. Added unit test for the use case.

## Phase 1: Backend Implementation (Domain & Data)
- [x] Run all tests to ensure the project is in a good state.
- [x] **Domain Layer:**
    - [x] Update `lib/features/booking/domain/repositories/booking_repository.dart` to include `getMyBookings(String userId)`.
    - [x] Create `lib/features/booking/domain/usecases/get_my_bookings.dart`.
- [x] **Data Layer:**
    - [x] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`.
        - [x] Add `getMyBookings(String userId)` method signature to abstract class.
        - [x] Implement method in `BookingRemoteDataSourceImpl` with Firestore query (`where userId == userId`, `orderBy startTime desc`).
    - [x] Update `lib/features/booking/data/repositories/booking_repository_impl.dart`.
        - [x] Implement `getMyBookings`.
- [x] **Dependency Injection:**
    - [x] Ensure `GetMyBookings` use case is registered (likely automatic with `@injectable`, but verify if manual registration is needed in `injection_container.dart` if not using generation for usecases).
    - [x] Run `dart run build_runner build --delete-conflicting-outputs` to update DI (if using injectable generator).
- [x] **Testing (Unit):**
    - [x] Create/Update unit tests for `BookingRepositoryImpl` (mocking datasource).
    - [x] Create unit test for `GetMyBookings` use case.
- [x] Run `dart_fix`.
- [x] Run `analyze_files`.
- [x] Run tests.
- [x] Run `dart_format`.
- [x] Verify changes with `git diff`.
- [x] Commit changes: `feat: implement backend logic for fetching user bookings`.

## Phase 2: Finalization
- [ ] Update `README.md` (if backend API docs were tracked there).
- [ ] Update `GEMINI.md` context.
- [ ] User Review.
