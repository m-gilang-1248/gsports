# MODIFICATION DESIGN: Fix Copy Button & Join Navigation

## Overview
This phase addresses UX gaps in the Split Bill feature: implementing the missing copy-to-clipboard functionality and improving the join flow to automatically navigate the user to the booking detail page.

## Problems & Solutions

### 1. Copy Button Inactive
- **Problem:** The copy button in `BookingDetailPage` does nothing when tapped.
- **Solution:** Implement `Clipboard.setData` and show a confirmation SnackBar.

### 2. Join Navigation Missing
- **Problem:** After successfully joining a booking via code, the user stays on the list page and has to manually find the booking.
- **Solution:**
    - Refactor `joinBooking` in backend to return the `bookingId`.
    - Update `HistoryBloc` to emit a `JoinSuccess` state containing the `bookingId`.
    - Update `BookingHistoryPage` to listen for this state and push to `/booking-detail/$bookingId`.

## Detailed Design

### 1. Backend Refactor (`JoinBooking`)
- **DataSource (`BookingRemoteDataSource`):**
    - `Future<void> joinBooking(...)` -> `Future<String> joinBooking(...)`
    - Return `bookingDocRef.id`.
- **Repository (`BookingRepository`):**
    - `Future<Either<Failure, void>> joinBooking(...)` -> `Future<Either<Failure, String>> joinBooking(...)`
- **UseCase (`JoinBooking`):**
    - Return `Future<Either<Failure, String>>`.

### 2. State Management (`HistoryBloc`)
Location: `lib/features/booking/presentation/bloc/history/history_bloc.dart`

- **State:** Add `JoinSuccess(String bookingId)` or add a property `joinedBookingId` to `HistoryLoaded`.
    - *Decision:* Since `HistoryLoaded` manages the list view, adding a transient property `String? joinedBookingId` to `HistoryLoaded` (or a separate side-effect state) is cleaner.
    - Let's use a specialized state `HistoryJoinSuccess(String bookingId)` that extends `HistoryState`, or modify `HistoryLoaded` to include it.
    - *Better approach for BlocListener:* Emit `HistoryJoinSuccess(bookingId)` temporarily, then emit `HistoryLoaded` (with refreshed data). This ensures the listener catches the event one-time.

### 3. UI Updates
- **`BookingDetailPage`:**
    - Use `flutter/services.dart` for `Clipboard`.
    - `ScaffoldMessenger.of(context).showSnackBar(...)`.
- **`BookingHistoryPage`:**
    - Update `BlocListener`:
        ```dart
        if (state is HistoryJoinSuccess) {
           context.push('/booking-detail/${state.bookingId}');
           // Bloc should automatically trigger refresh or UI should request it?
           // Bloc can trigger refresh after emitting Success.
        }
        ```

## Summary
These improvements significantly enhance the usability of the Split Bill feature by providing immediate feedback and seamless navigation.
