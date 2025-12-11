# Modification Design: Booking History UI (Iteration 2)

## 1. Overview
This iteration focuses on the user interface for the Booking History feature. We will implement a dedicated BLoC (`HistoryBloc`) to manage the state of the booking list and create the `BookingHistoryPage` to display these bookings using the design system's card style.

## 2. Problem Analysis
*   **Goal:** Display the user's booking history in a list format on the "My Bookings" tab.
*   **Current State:** Backend logic (`GetMyBookings`) is ready. The UI is currently a placeholder (`MyBookingsPage`).
*   **Requirements:**
    *   Fetch data using `GetMyBookings`.
    *   Display `Venue Name`, `Date`, `Time`, and `Status` (colored chips).
    *   Handle Loading and Error states.
    *   Use `OutlinedCard` style (Elevation 0, Border Grey-300).

## 3. Solution Design

### A. Presentation Layer (BLoC)
*   **Name:** `HistoryBloc`
*   **Path:** `lib/features/booking/presentation/bloc/history/`
*   **Events:**
    *   `FetchBookingHistory`: Triggers the use case.
*   **States:**
    *   `HistoryInitial`
    *   `HistoryLoading`
    *   `HistoryLoaded(List<Booking> bookings)`
    *   `HistoryError(String message)`
*   **Dependencies:** `GetMyBookings` use case, `AuthBloc` (to get `userId`).

### B. Presentation Layer (UI)
*   **Page:** `BookingHistoryPage` (`lib/features/booking/presentation/pages/booking_history_page.dart`).
*   **Components:**
    *   `BookingHistoryCard`: A stateless widget representing a single booking item.
        *   **Layout:**
            *   **Row 1:** Venue Name (Bold) + Status Chip (Right).
            *   **Row 2:** Sport Type (Icon/Text).
            *   **Row 3:** Date & Time.
        *   **Styling:**
            *   Background: White.
            *   Border: `Colors.grey[300]`.
            *   Status Colors:
                *   Paid/Settlement: Green.
                *   Waiting Payment/Pending: Orange/Amber.
                *   Cancelled/Expire/Deny: Red.
*   **Integration:**
    *   Update `MainPage` to use `BookingHistoryPage` instead of `MyBookingsPage`.
    *   **Auth Requirement:** The page must ensure the user is logged in to get the `userId`. We can retrieve `userId` from `AuthBloc` state or `FirebaseAuth.instance.currentUser`. Since we are in the authenticated shell, `currentUser` should be available.

## 4. Detailed Design

### HistoryBloc
```dart
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyBookings getMyBookings;
  final AuthBloc authBloc; // Optional, or just pass userId in event

  HistoryBloc({required this.getMyBookings}) : super(HistoryInitial()) {
    on<FetchBookingHistory>(_onFetchHistory);
  }

  Future<void> _onFetchHistory(FetchBookingHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    final result = await getMyBookings(event.userId);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (bookings) => emit(HistoryLoaded(bookings)),
    );
  }
}
```

### BookingHistoryCard
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    side: BorderSide(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(venueName, style: TextStyle(fontWeight: FontWeight.bold)), // Note: Booking entity has venueId, we might need to fetch Venue name or store it in Booking (Denormalization). 
            // *CRITICAL NOTE*: The Schema shows Booking has venueId but not venueName.
            // For MVP/Speed, we might just show "Venue ID: ..." or if possible, the backend should have returned populated data. 
            // HOWEVER, looking at Schema, it has `venueId`. 
            // SOLUTION: For now, we will display "Venue #${booking.venueId.substring(0,4)}" or similar if name isn't available, 
            // OR checks if we can fetch venue details. 
            // BETTER SOLUTION (MVP): Just display "Sport Type" or generic "Venue Booking" if name is missing.
            // WAIT: The Schema in Implementation phase description didn't enforce denormalization.
            // Let's check `Booking` entity. 
          ],
        ),
        // ...
      ],
    ),
  ),
)
```
*Self-Correction on Venue Name:* The `Booking` entity only has `venueId`. Fetching venue details for every booking in a list is N+1 problem.
*Strategy:* For this iteration, we will display the **Sport Type** prominent or "Venue Name" if we decide to add it to `Booking` entity (which involves backend changes).
*Decided:* We will just display the `venueId` (shortened) or `Sport Type` as the title for now to stick to the plan constraints (only UI work). **OR** simpler: Use `Sport Type` as the main title (e.g., "Badminton Match").

## 5. Alternatives Considered
*   **Pagination:** Infinite scroll. *Decision:* Rejected for MVP (user preference).
*   **Denormalization:** Storing `venueName` in `bookings` collection. *Decision:* Would require backend refactor. We will stick to available data.

## 6. References
*   [Flutter Cards](https://api.flutter.dev/flutter/material/Card-class.html)
*   [Flutter Chips](https://api.flutter.dev/flutter/material/Chip-class.html)
