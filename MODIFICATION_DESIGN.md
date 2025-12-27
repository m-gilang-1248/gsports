# MODIFICATION DESIGN: Sprint 11 - Order Management (Mitra)

**Date:** 27 December 2025
**Status:** Planned
**Target Module:** `features/partner/booking_management`

## 1. Overview
Fitur ini memberikan kemampuan bagi Mitra (Owner Venue) untuk mengelola pesanan yang masuk, melihat jadwal dalam bentuk kalender, dan melakukan pemblokiran slot secara manual (untuk tamu walk-in/offline).

## 2. Dependencies
*   `table_calendar`: ^3.2.0 (Added)
*   `intl`: (Existing)
*   `flutter_bloc`: (Existing)

## 3. Architecture & Data Layer

### A. Firestore Query Update
*   **Collection:** `bookings`
*   **Index Requirement:** `ownerId` (Ascending) + `date` (Ascending).
*   **Query Pattern:**
    ```dart
    firestore.collection('bookings')
      .where('ownerId', isEqualTo: currentUserId)
      .orderBy('date', descending: true) // Newest dates first
      .get();
    ```

### B. Domain Layer Extensions
Lokasi: `lib/features/booking/domain/`

1.  **New UseCase:** `GetPartnerBookings`
    *   **Input:** `ownerId` (String)
    *   **Output:** `List<Booking>`
    *   **Logic:** Memanggil repository untuk mengambil semua booking milik mitra.

2.  **Existing UseCase Reuse:** `CreateBooking`
    *   Digunakan untuk fitur "Manual Blocking" (Walk-in).
    *   Payload khusus: `paymentStatus: 'manual_offline'`, `status: 'paid'`.

### C. Repository Interface Update
File: `lib/features/booking/domain/repositories/booking_repository.dart`
```dart
Future<Either<Failure, List<Booking>>> getPartnerBookings(String ownerId);
```

## 4. UI/UX Design

### A. Entry Point
*   **Page:** `OwnerDashboardPage`
*   **Component:** Tambahkan Menu/Card baru di grid atau list navigasi bernama "Order Management" atau "Jadwal Pesanan".

### B. Order Management Page (`OrderManagementPage`)
Halaman utama dengan struktur Tab View.

**Structure:**
*   **AppBar:** Title "Pesanan Masuk".
*   **Body:**
    *   **Mode Toggle:** Segmented Button [List View | Calendar View]
    *   **View 1: List View (Tabbed)**
        *   **Tab 1: Perlu Konfirmasi** (`status == 'waiting_payment'`)
            *   *Note:* Di MVP ini, mostly `waiting_payment` dari Midtrans. Jika nanti ada fitur manual transfer, tab ini krusial.
        *   **Tab 2: Jadwal** (`status == 'paid'`)
            *   List booking aktif yang akan datang.
        *   **Tab 3: Riwayat** (`status == 'completed' || 'cancelled'`)
            *   Arsip pesanan lampau.
    *   **View 2: Calendar View**
        *   Widget: `TableCalendar`.
        *   **Markers:** Dot marker di tanggal yang memiliki booking.
        *   **OnDaySelected:** Tampilkan BottomSheet atau List di bawah kalender berisi booking pada tanggal tersebut.

**UI Components:**
*   `BookingOrderCard`:
    *   Info: Jam Main, Nama Lapangan, Nama User (Host).
    *   Status Strip: Warna visual di kiri card (Kuning=Pending, Hijau=Paid, Merah=Cancel, Abu=Selesai).

### C. Manual Blocking Form (`ManualBookingPage`)
Fitur untuk memblokir slot bagi tamu offline.

*   **Trigger:** FAB "Input Manual" di halaman `OrderManagementPage`.
*   **Form Fields:**
    1.  **Select Venue:** Dropdown (Load from `VenueManagementBloc`).
    2.  **Select Court:** Dropdown (Dependent on Venue).
    3.  **Date Picker:** Pilih Tanggal.
    4.  **Time Slots:** Grid Selection (Reuse logic from Booking User Side).
    5.  **Customer Name:** Text Field (Optional, default "Walk-in Guest").
*   **Submit Action:**
    *   Create Booking dengan:
        *   `userId`: `ownerId` (Self-booking) atau dedicated 'guest_offline' ID.
        *   `paymentStatus`: `manual_offline`.
        *   `status`: `paid` (Langsung confirm).

## 5. State Management (BLoC)

### A. `OrderManagementBloc`
Mengelola state list pesanan mitra.

*   **Events:**
    *   `FetchPartnerBookings`: Load data awal.
    *   `FilterOrders`: Filter by status (lokal filter di memory).
    *   `UpdateCalendarFocusedDay`: Saat user geser bulan kalender.
*   **States:**
    *   `OrderManagementLoading`
    *   `OrderManagementLoaded`:
        *   `allBookings`: List<Booking> (Master data)
        *   `filteredBookings`: List<Booking> (Tampilan saat ini)
        *   `bookingsByDate`: Map<DateTime, List<Booking>> (Untuk calendar markers)
    *   `OrderManagementFailure`

## 6. Implementation Steps (Execution Plan)

1.  **Data Layer:**
    *   Update `BookingRemoteDataSource` (add `getPartnerBookings`).
    *   Update `BookingRepositoryImpl`.

2.  **Domain Layer:**
    *   Create `GetPartnerBookings` UseCase.
    *   Update `BookingRepository` interface.

3.  **Presentation (Bloc):**
    *   Generate `OrderManagementBloc`.
    *   Inject dependencies (`GetPartnerBookings`).

4.  **Presentation (UI):**
    *   Create `BookingOrderCard` widget.
    *   Create `OrderManagementPage` (Tabs + List View).
    *   Implement `TableCalendar` integration.
    *   Create `ManualBookingPage` (Form Walk-in).

5.  **Integration:**
    *   Link to `AppRouter`.
    *   Add Entry Point in `OwnerDashboardPage`.