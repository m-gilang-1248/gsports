# MODIFICATION IMPLEMENTATION PLAN: Sprint 11 - Order Management

**Date:** 27 December 2025
**Module:** `features/partner/booking_management`

## Phase 1: Domain & Data Layer (Foundation)

### 1.1 Update Remote Data Source
**File:** `lib/features/booking/data/datasources/booking_remote_data_source.dart`
*   **Method:** `getPartnerBookings(String ownerId)`
*   **Query:**
    ```dart
    firestore.collection('bookings')
      .where('ownerId', isEqualTo: ownerId)
      // Note: We might sort client-side initially to avoid complex composite index creation immediately,
      // or ensure Index (ownerId ASC, date DESC) exists.
      .get();
    ```

### 1.2 Update Repository
**File:** `lib/features/booking/domain/repositories/booking_repository.dart`
*   Add interface: `Future<Either<Failure, List<Booking>>> getPartnerBookings(String ownerId);`

**File:** `lib/features/booking/data/repositories/booking_repository_impl.dart`
*   Implement method calling `remoteDataSource`.

### 1.3 Create Use Case
**File:** `lib/features/booking/domain/usecases/get_partner_bookings.dart`
*   Standard UseCase boilerplate invoking repository.

---

## Phase 2: State Management (BLoC)

### 2.1 Create BLoC Structure
**Folder:** `lib/features/partner/booking_management/presentation/bloc/`
*   `order_management_bloc.dart`
*   `order_management_event.dart`
*   `order_management_state.dart`

### 2.2 Implement Logic (Crucial Logic Here)
**File:** `order_management_bloc.dart`

*   **State Properties:**
    *   `allBookings`: List<Booking> (Raw data)
    *   `pendingBookings`: List<Booking> (Filter: `waiting_payment`)
    *   `upcomingBookings`: List<Booking> (Filter: `paid` && `date >= today`) -> **SORT: Ascending (Nearest First)**
    *   `historyBookings`: List<Booking> (Filter: `completed` || `cancelled` || `date < today`) -> **SORT: Descending (Newest First)**
    *   `bookingsByDate`: `Map<DateTime, List<Booking>>` (For Calendar)

*   **Date Normalization Logic (For Calendar Map):**
    ```dart
    DateTime normalizeDate(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }
    // When mapping:
    final key = normalizeDate(booking.date);
    if (!map.containsKey(key)) map[key] = [];
    map[key]!.add(booking);
    ```

---

## Phase 3: UI Implementation

### 3.1 Booking Order Card
**File:** `lib/features/partner/booking_management/presentation/widgets/booking_order_card.dart`
*   Design: Card with left-side color strip based on status.
*   Props: `Booking` object.

### 3.2 Order Management Page
**File:** `lib/features/partner/booking_management/presentation/pages/order_management_page.dart`
*   **Widgets:**
    *   `SegmentedButton` (List vs Calendar).
    *   `TabBar` & `TabBarView` (Pending, Jadwal, Riwayat).
    *   `TableCalendar`:
        *   `eventLoader`: Bind to `bookingsByDate[normalizeDate(day)]`.
        *   `onDaySelected`: Show BottomSheet or filter list below.

### 3.3 Manual Booking (Walk-in) Form
**File:** `lib/features/partner/booking_management/presentation/pages/manual_booking_page.dart`
*   Reuse `BookingBloc` logic but force `paymentStatus: 'manual_offline'`.

---

## Phase 4: Integration

### 4.1 Dependency Injection
**File:** `lib/injection_container.dart`
*   Register `GetPartnerBookings` (lazySingleton).
*   Register `OrderManagementBloc` (factory).

### 4.2 Navigation
**File:** `lib/core/config/router.dart`
*   Add route `/partner/orders`.
*   Add route `/partner/manual-booking`.

### 4.3 Dashboard Entry
**File:** `lib/features/partner/dashboard/presentation/pages/owner_dashboard_page.dart`
*   Add Button/Card linking to `/partner/orders`.

---

## Phase 5: Verification
*   **Test Case 1:** Mitra login -> Buka Order Management -> Load Data.
*   **Test Case 2:** Tab Jadwal sorted terdekat dulu.
*   **Test Case 3:** Tab Riwayat sorted terbaru dulu.
*   **Test Case 4:** Calendar View muncul dot marker di tanggal ada booking.
*   **Test Case 5:** Klik tanggal di calendar -> List di bawah terupdate.
