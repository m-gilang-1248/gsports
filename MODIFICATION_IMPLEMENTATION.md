# Implementation Plan: Booking History UI

## Journal
- **Iteration 2 Start:** Starting implementation of backend logic for fetching user booking history.
- **Phase 1 Completed:** Implemented `GetMyBookings` use case, updated `BookingRepository` and `BookingRemoteDataSource` with Firestore query logic.
- **Iteration 3 Start (UI):** Starting implementation of Booking History UI. User approved using `sportType` as card title.
- **Iteration 3 Status:** Bloc and UI Page implemented. Widget Testing skipped due to environment configuration issues.

## Phase 1: Presentation Layer (Bloc)
- [x] Run all tests to ensure the project is in a good state.
- [x] Create `lib/features/booking/presentation/bloc/history/history_event.dart`.
    - [x] Define `HistoryEvent` (abstract) and `FetchBookingHistory` (class with `userId`).
- [x] Create `lib/features/booking/presentation/bloc/history/history_state.dart`.
    - [x] Define `HistoryState` (abstract), `HistoryInitial`, `HistoryLoading`, `HistoryLoaded` (with `List<Booking>`), `HistoryError`.
- [x] Create `lib/features/booking/presentation/bloc/history/history_bloc.dart`.
    - [x] Implement `HistoryBloc` using `GetMyBookings` use case.
- [x] **Dependency Injection:**
    - [x] Register `HistoryBloc` in `injection_container.dart` (using `@injectable`).
    - [x] Run `dart run build_runner build --delete-conflicting-outputs`.
- [x] **Testing (Unit):**
    - [x] Create unit test for `HistoryBloc` (`test/features/booking/presentation/bloc/history/history_bloc_test.dart`).

## Phase 2: Presentation Layer (UI)
- [x] Create `lib/features/booking/presentation/pages/booking_history_page.dart`.
    - [x] Implement `BookingHistoryPage` (Stateless/Stateful).
    - [x] Use `BlocProvider` to provide `HistoryBloc` (getting `userId` from `FirebaseAuth` or `AuthBloc`).
    - [x] Use `BlocBuilder` to handle states (Loading, Error, Loaded).
    - [x] Implement `BookingHistoryCard` widget (Outlined Card).
        - [x] Title: `sportType` (Capitalized).
        - [x] Subtitle: Date & Time.
        - [x] Status Chip: Color-coded based on `paymentStatus` or `status`.
- [x] **Integration:**
    - [x] Update `lib/core/presentation/pages/main_page.dart`.
        - [x] Replace `MyBookingsPage` with `BookingHistoryPage`.
    - [x] Delete `lib/features/booking/presentation/pages/my_bookings_page.dart`.
- [ ] **Testing (Widget):**
    - [ ] Create widget test for `BookingHistoryPage` (verify loading and list rendering). **(SKIPPED)**
- [ ] Run `dart_fix`.
- [ ] Run `analyze_files`.
- [ ] Run tests.
- [ ] Run `dart_format`.
- [ ] Verify changes with `git diff`.
- [ ] Commit changes: `feat: implement booking history ui`.
- [ ] Hot Reload.

## Phase 3: Finalization
- [ ] Update `README.md`.
- [ ] Update `GEMINI.md` context.
- [ ] User Review.