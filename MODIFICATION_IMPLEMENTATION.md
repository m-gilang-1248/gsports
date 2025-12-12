# MODIFICATION IMPLEMENTATION PLAN: Split Bill Feature (UI & Detail Logic)

This plan covers the implementation of the Booking Detail page, including the necessary backend logic for fetching a single booking and the state management.

## Phase 1: Backend & Repository Updates
**Goal:** Enable fetching a single booking by ID.

- [x] Run all tests to ensure the project is in a good state.
- [x] Create `lib/features/booking/domain/usecases/get_booking_detail.dart`.
- [x] Update `lib/features/booking/domain/repositories/booking_repository.dart`:
    - Add `Future<Either<Failure, Booking>> getBookingDetail(String bookingId);`.
- [x] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`:
    - Add `Future<BookingModel> getBookingDetail(String bookingId);`.
- [x] Update `lib/features/booking/data/repositories/booking_repository_impl.dart`:
    - Implement `getBookingDetail`.
- [x] Implement `getBookingDetail` in `BookingRemoteDataSourceImpl`.
- [x] Create unit tests for `GetBookingDetail` use case.
- [x] Run `dart_fix` and `dart_format`.
- [x] Run tests.
- [x] Commit changes.

## Phase 2: State Management (BookingDetailBloc)
**Goal:** Manage the state of the Booking Detail page.

- [x] Create `lib/features/booking/presentation/bloc/detail/booking_detail_event.dart`.
- [x] Create `lib/features/booking/presentation/bloc/detail/booking_detail_state.dart`.
- [x] Create `lib/features/booking/presentation/bloc/detail/booking_detail_bloc.dart`.
    - Handle `FetchBookingDetail`.
    - Handle `GenerateCodeRequested` (call `GenerateSplitCode` use case, then refresh).
- [x] Register `BookingDetailBloc` in dependency injection (`injection_container.dart`).
- [x] Create unit tests for `BookingDetailBloc`.
- [x] Run `dart_fix` and `dart_format`.
- [x] Run tests.
- [ ] Commit changes.

## Phase 3: UI Implementation (BookingDetailPage)
**Goal:** Build the UI for displaying booking details and managing split bill.

- [ ] Create `lib/features/booking/presentation/pages/booking_detail_page.dart`.
    - Implement the layout defined in the design doc (Header, Split Bill Section, Participants).
    - Integrate `BookingDetailBloc`.
- [ ] Update `lib/core/routes/app_router.dart` (or `main.dart` if simple routing) to add the `/booking-detail/:id` route.
- [ ] Update `lib/features/booking/presentation/pages/booking_history_page.dart` to navigate to Detail Page on tap.
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Verify UI with a manual run (hot reload/restart).
- [ ] Commit changes.

## Phase 4: Finalize
- [ ] Update `GEMINI.md`.
- [ ] Ask user for final review.

## Journal
*   Phase 1: Implemented GetBookingDetail use case, updated BookingRepository and BookingRemoteDataSource. Created unit tests for GetBookingDetail and resolved issues with mocktail fallback values. All tests passed. Committed changes with message "feat: add GetBookingDetail use case, repo, datasource".
*   Phase 2: Created BookingDetail Bloc, Events, and States. Registered Bloc via injectable. Added bloc_test dependency. Fixed import issues in Bloc and test files. Wrote comprehensive unit tests for BookingDetailBloc covering fetching and code generation. All tests passed.
