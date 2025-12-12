# MODIFICATION IMPLEMENTATION PLAN: Fix Data Layer (Sorting & Join Query)

This plan covers the fixes for booking history sorting and the join booking query logic.

## Phase 1: Fix Booking History Sorting
**Goal:** Ensure bookings are listed from newest to oldest.

- [ ] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`:
    - In `getMyBookings`, ensure `.orderBy('startTime', descending: true)` is used.
- [ ] Verify sorting with a manual test (run app and check list order).

## Phase 2: Fix Join Booking Query & Logic
**Goal:** Ensure users can join bookings reliably.

- [ ] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`:
    - In `joinBooking`, sanitize input: `splitCode.trim().toUpperCase()`.
    - Add debug print: `print('DEBUG JOIN: Searching for code [$cleanCode] in collection bookings');`.
    - Ensure query uses the sanitized `cleanCode`.
    - In `generateSplitCode`, ensure the generated code is also upper-cased (though it likely is from the char set, explicit is better).
- [ ] Verify join functionality with a manual test.
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Commit changes.

## Phase 3: Finalize
- [ ] Update `GEMINI.md`.
- [ ] Ask user for final review.

## Journal
*   (To be updated)
