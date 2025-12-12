# MODIFICATION IMPLEMENTATION PLAN: Fix Copy Button & Join Navigation

This plan covers the implementation of the copy-to-clipboard feature and the refactoring of the Join Booking flow for automatic navigation.

## Phase 1: Backend Refactor (Return Booking ID)
**Goal:** Modify `JoinBooking` to return the `bookingId` of the joined booking.

- [x] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`:
    - Change `joinBooking` return type to `Future<String>`.
    - Return `bookingDocRef.id` after successful update.
- [x] Update `lib/features/booking/domain/repositories/booking_repository.dart`:
    - Change `joinBooking` return type to `Future<Either<Failure, String>>`.
- [x] Update `lib/features/booking/data/repositories/booking_repository_impl.dart`:
    - Update `joinBooking` implementation to match new signature and return `Right(bookingId)`.
- [x] Update `lib/features/booking/domain/usecases/join_booking.dart`:
    - Change return type to `Future<Either<Failure, String>>`.
- [x] Update tests in `test/features/booking/domain/usecases/split_bill_usecases_test.dart` to match new return types.
- [x] Run `dart_fix` and `dart_format`.
- [x] Run tests.
- [x] Commit changes.

## Phase 2: State Management Update (HistoryBloc)
**Goal:** Emit a state with `bookingId` upon successful join.

- [x] Update `lib/features/booking/presentation/bloc/history/history_state.dart`:
    - Add `HistoryJoinSuccess` state with `final String bookingId`.
- [x] Update `lib/features/booking/presentation/bloc/history/history_bloc.dart`:
    - Update `_onJoinBookingRequested`:
        - Await result from `_joinBooking`.
        - If success (Right(bookingId)), emit `HistoryJoinSuccess(bookingId)`.
        - Then emit `HistoryLoading` (or maintain loading) and trigger `FetchBookingHistory` to refresh the list. *Wait, if we emit Fetch, it might overwrite JoinSuccess too fast. Let's emit JoinSuccess, then the UI Listener handles navigation, and WE ALSO add the Fetch event.*
- [x] Update `test/features/booking/presentation/bloc/history/history_bloc_test.dart`.
- [x] Run tests.
- [x] Commit changes.

## Phase 3: UI Implementation
**Goal:** Implement Copy Button and Join Navigation.

- [ ] Update `lib/features/booking/presentation/pages/booking_detail_page.dart`:
    - Implement `onPressed` for Copy Icon.
    - Use `Clipboard.setData`.
    - Show SnackBar.
- [ ] Update `lib/features/booking/presentation/pages/booking_history_page.dart`:
    - Update `BlocListener` to handle `HistoryJoinSuccess`.
    - Navigate to `'/booking-detail/$bookingId'` using `context.push`.
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Manual verification.
- [ ] Commit changes.

## Phase 4: Finalize
- [ ] Update `GEMINI.md`.
- [ ] Ask user for final review.

## Journal
*   Phase 1: Backend Refactor: Modified `joinBooking` in `BookingRemoteDataSource`, `BookingRepository`, and `JoinBooking` use case to return `bookingId` on success. Updated corresponding tests in `split_bill_usecases_test.dart`. All tests passed. Committed changes with message "refactor: JoinBooking returns bookingId for navigation".
*   Phase 2: State Management Update: Added `HistoryJoinSuccess` state to `history_state.dart`. Updated `history_bloc.dart` to emit `HistoryJoinSuccess` on successful join and then trigger `FetchBookingHistory`. Updated `history_bloc_test.dart` to reflect these changes and fixed multiple issues with test setup and `mockFirebaseAuth` stubbing. All tests passed.