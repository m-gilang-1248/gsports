# Implementation Plan: UI Refinement & Status Management

## Phase 1: Bloc Updates
- [x] **Inject UseCase:** Update `BookingDetailBloc` to depend on `UpdateParticipantStatus`.
- [x] **Define Event:** Add `UpdateParticipantPaymentStatus` event to `BookingDetailEvent`.
- [x] **Implement Logic:** Handle the new event in `BookingDetailBloc` (call usecase -> refresh).
- [x] **Register DI:** Ensure `BookingDetailBloc` is correctly registered with the new dependency in `injection_container.dart` (or auto-generated).

## Phase 2: UI Refactoring (BookingDetailPage)
- [x] **Header Info:** Add "Dibuat pada" and "Estimasi Patungan" to `_buildBookingInfoCard`.
    -   Use `NumberFormat` for currency.
    -   Handle division safety.
- [x] **Participant List Logic:** Update `_buildParticipantTile`.
    -   Check `currentUser.uid == booking.userId` (Host Check).
    -   If Host: Add `IconButton` (Edit) for *other* participants.
- [x] **Interaction:** Implement the "Edit Status" dialog/bottom sheet.
    -   Options: "Mark as Paid", "Mark as Pending".
    -   Trigger `context.read<BookingDetailBloc>().add(UpdateParticipantPaymentStatus(...))`.
- [x] **Styling:** Refine status chips (Green for Paid, Orange for Pending).

## Phase 3: Verification & Cleanup
- [ ] **Run Analysis:** `analyze_files`.
- [ ] **Format Code:** `dart_format`.
- [ ] **Commit:** `feat(ui): refine booking detail and add host controls`.

## Journal
- **2025-12-13**: Plan created.
- **2025-12-13**: Phase 1 (UI Refinement & Status Management) completed:
    - Injected `UpdateParticipantStatus` into `BookingDetailBloc`.
    - Added `UpdateParticipantPaymentStatus` event to `booking_detail_event.dart`.
    - Implemented `_onUpdateParticipantPaymentStatus` in `BookingDetailBloc` to call the use case and refresh.
    - Updated `BookingDetailLoaded` state to include `isUpdatingParticipant` for UI feedback.
    - Ran `build_runner` successfully to update DI.
- **2025-12-13**: Phase 2 (UI Refactoring) completed:
    - Updated `_buildBookingInfoCard` to display booking creation date and estimated share per person, with currency formatting and division safety.
    - Modified `_buildSplitBillSection` to correctly pass `isHost`.
    - Refactored `_buildParticipantsSection` and `_buildParticipantTile` to differentiate host/guest views and enable host to update participant payment status via a dialog.
    - Implemented `_showUpdateStatusDialog` for status modification.
    - Refined styling of payment status chips with appropriate colors (`green` for 'Lunas', `orange` for 'Pending').
    - Fixed breaking changes in test files (`booking_detail_bloc_test.dart`, `get_my_bookings_test.dart`, `split_bill_usecases_test.dart`, `history_bloc_test.dart`) by adding `createdAt` to `Booking` instantiations and correcting mocktail fallback registration.
    - All tests passed after fixes.