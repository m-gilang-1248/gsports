# Implementation Plan: Booking History Backend

## Journal
- **Iteration 2 Start:** Starting implementation of backend logic for fetching user booking history.

## Phase 1: Backend Implementation (Domain & Data)
- [ ] Run all tests to ensure the project is in a good state.
- [ ] **Domain Layer:**
    - [ ] Update `lib/features/booking/domain/repositories/booking_repository.dart` to include `getMyBookings(String userId)`.
    - [ ] Create `lib/features/booking/domain/usecases/get_my_bookings.dart`.
- [ ] **Data Layer:**
    - [ ] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`.
        - [ ] Add `getMyBookings(String userId)` method signature to abstract class.
        - [ ] Implement method in `BookingRemoteDataSourceImpl` with Firestore query (`where userId == userId`, `orderBy startTime desc`).
    - [ ] Update `lib/features/booking/data/repositories/booking_repository_impl.dart`.
        - [ ] Implement `getMyBookings`.
- [ ] **Dependency Injection:**
    - [ ] Ensure `GetMyBookings` use case is registered (likely automatic with `@injectable`, but verify if manual registration is needed in `injection_container.dart` if not using generation for usecases).
    - [ ] Run `dart run build_runner build --delete-conflicting-outputs` to update DI (if using injectable generator).
- [ ] **Testing (Unit):**
    - [ ] Create/Update unit tests for `BookingRepositoryImpl` (mocking datasource).
    - [ ] Create unit test for `GetMyBookings` use case.
- [ ] Run `dart_fix`.
- [ ] Run `analyze_files`.
- [ ] Run tests.
- [ ] Run `dart_format`.
- [ ] Verify changes with `git diff`.
- [ ] Commit changes: `feat: implement backend logic for fetching user bookings`.

## Phase 2: Finalization
- [ ] Update `README.md` (if backend API docs were tracked there).
- [ ] Update `GEMINI.md` context.
- [ ] User Review.