# Modification Design: Booking History Backend (Iteration 2)

## 1. Overview
This iteration focuses on implementing the backend logic (Domain and Data layers) required to fetch the booking history for the currently logged-in user. This is a foundational step for the "My Bookings" feature.

## 2. Problem Analysis
*   **Goal:** Retrieve a list of bookings where the `userId` matches the current authenticated user's ID.
*   **Current State:** The `BookingRepository` likely has methods for creating bookings, but not for fetching them by user.
*   **Data Structure:** Firestore `bookings` collection contains a `userId` field.
*   **Requirements:**
    *   Filter by `userId`.
    *   Sort by `date` (descending) or `startTime` (descending) to show newest first.
    *   Return a `List<Booking>`.

## 3. Solution Design

### A. Domain Layer
1.  **Entity:** `Booking` entity already exists.
2.  **Repository Interface:** Add `getMyBookings` to `BookingRepository`.
    ```dart
    Future<Either<Failure, List<Booking>>> getMyBookings(String userId);
    ```
3.  **UseCase:** Create `GetMyBookings`.
    ```dart
    class GetMyBookings implements UseCase<List<Booking>, String> { ... }
    ```

### B. Data Layer
1.  **Remote Data Source:**
    *   Update `BookingRemoteDataSource` with `getMyBookings(String userId)`.
    *   **Query:**
        ```dart
        firestore.collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true) // Using startTime is more precise than date string
          .get();
        ```
    *   **Mapping:** Convert `QuerySnapshot` to `List<BookingModel>`.
2.  **Repository Implementation:**
    *   Implement `getMyBookings` in `BookingRepositoryImpl`.
    *   Call datasource and map `BookingModel` to `Booking` entity.

### C. Dependency Injection
*   Register `GetMyBookings` as a factory in `injection_container.dart` (using `@injectable`).

## 4. Detailed Design

### BookingRemoteDataSource
```dart
abstract class BookingRemoteDataSource {
  // ... existing methods
  Future<List<BookingModel>> getMyBookings(String userId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  // ...
  @override
  Future<List<BookingModel>> getMyBookings(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }
}
```

## 5. Alternatives Considered
*   **Pagination:** Creating a paginated query (using `startAfter`, `limit`).
    *   *Decision:* Deferred to a future optimization phase as per user instruction. Fetching all for MVP is acceptable.
*   **Sorting Field:** `date` string vs `startTime` timestamp.
    *   *Decision:* `startTime` is better for precise sorting (descending). `date` is a string `YYYY-MM-DD` which is okay but `startTime` handles same-day sorting naturally.

## 6. References
*   [Firestore Simple Queries](https://firebase.google.com/docs/firestore/query-data/queries)
*   [Firestore Order Limit Data](https://firebase.google.com/docs/firestore/query-data/order-limit-data)