# MODIFICATION DESIGN: Fix Data Layer (Sorting & Join Query)

## Overview
This phase addresses critical issues in the data layer regarding the sorting of booking history and the robustness of the "Join Booking" query.

## Problems & Solutions

### 1. Booking History Sorting
- **Problem:** Bookings are sorted ascending (oldest first) or by string date, which is imprecise.
- **Solution:** Update `getMyBookings` in `BookingRemoteDataSource` to sort by `startTime` (Timestamp) in descending order.

### 2. Join Booking Query Failure
- **Problem:** Users cannot join a booking even with the correct code. Likely due to input formatting issues (spaces, case sensitivity).
- **Solution:**
    - Sanitize `splitCode` input in `joinBooking` (trim, uppercase).
    - Add debug logging to trace the query.
    - Ensure `generateSplitCode` also enforces this consistency.

## Detailed Design

### `BookingRemoteDataSourceImpl` Updates
Location: `lib/features/booking/data/datasources/booking_remote_data_source.dart`

**Method: `getMyBookings`**
```dart
@override
Future<List<BookingModel>> getMyBookings(String userId) async {
  // ...
  .orderBy('startTime', descending: true) // Ensure this is strict
  // ...
}
```

**Method: `joinBooking`**
```dart
@override
Future<void> joinBooking(String splitCode, PaymentParticipant participant) async {
  final cleanCode = splitCode.trim().toUpperCase();
  print('DEBUG JOIN: Searching for code [$cleanCode]');
  
  final querySnapshot = await firestore
      .collection('bookings')
      .where('splitCode', isEqualTo: cleanCode) // Use cleanCode
      .limit(1)
      .get();
  // ...
}
```

**Method: `generateSplitCode`**
```dart
// Ensure generated code is consistent
String _generateRandomCode() {
  // ...
  return code.toUpperCase(); // Explicitly uppercase
}
```

## Summary
These changes will fix the immediate usability issues of the Booking History and Join features.