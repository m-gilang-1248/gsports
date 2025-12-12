# MODIFICATION DESIGN: Fix Bugs & Implement Join UI

## Overview
This phase addresses critical bugs identified in the `BookingModel` serialization and navigation, and implements the "Join Booking" feature via UI and BLoC updates.

## Problems & Solutions

### 1. Serialization Error in `BookingModel`
- **Problem:** `participants` list is being serialized as a list of `PaymentParticipantModel` objects, but Firestore requires a list of Maps (`List<Map<String, dynamic>>`).
- **Solution:** Override `toJson()` in `BookingModel` to explicitly convert `participants` to `List<Map<String, dynamic>>`.

### 2. Navigation Issue in `BookingHistoryPage`
- **Problem:** Using `context.go` replaces the navigation stack, causing the back button to exit the app or behave unexpectedly.
- **Solution:** Use `context.push` to add the `BookingDetailPage` to the stack, allowing normal back navigation.

### 3. Missing Join Feature
- **Problem:** Users have no way to input a code to join a booking.
- **Solution:**
    - Add a FAB to `BookingHistoryPage`.
    - Show a dialog for code input.
    - Handle the join logic in `HistoryBloc` (since it manages the list view and joining affects the list).

## Detailed Design

### 1. `BookingModel` Update
Location: `lib/features/booking/data/models/booking_model.dart`

```dart
@override
Map<String, dynamic> toJson() {
  final json = _$BookingModelToJson(this);
  json['participants'] = participants.map((e) => e.toJson()).toList();
  return json;
}
```

### 2. `HistoryBloc` Update
Location: `lib/features/booking/presentation/bloc/history/history_bloc.dart`

- **Event:** `JoinBookingRequested(String splitCode)`
- **State:** `JoinLoading`, `JoinSuccess`, `JoinError` (These might need to be handled separately from the main `HistoryState` to avoid clearing the list, or we use `Listen` side effects).
- **UseCase:** Inject `JoinBooking`.

**Refined Bloc Approach:**
To avoid messing up the `HistoryState` (which holds the list of bookings), we will use a `BlocListener` in the UI to handle success/error messages, and simply refresh the list (`FetchBookingHistory`) upon success. The `HistoryBloc` will handle the logic.

### 3. UI Updates
Location: `lib/features/booking/presentation/pages/booking_history_page.dart`

- **FAB:** `FloatingActionButton` with `Icons.group_add`.
- **Dialog:** `showDialog` with `TextField`.
- **Logic:** Dispatch `JoinBookingRequested` -> Wait for result -> Dispatch `FetchBookingHistory`.

## Summary
These fixes will ensure the app doesn't crash on booking creation or navigation, and finally allows users to join bookings.
