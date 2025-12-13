# Implementation Plan: History Sorting & Dialog Provider Scope Fixes

## Phase 1: History Sorting Verification & Fix
- [x] **Verify Query:** In `lib/features/booking/data/datasources/booking_remote_data_source.dart`, verified `getMyBookings` uses `.orderBy('startTime', descending: true)`. No change needed as this sorts newest first.
- [x] **Verify UI:** In `lib/features/booking/presentation/pages/booking_history_page.dart`, verified `ListView` is not using `reverse: true` or any manual list reversal. No change needed.

## Phase 2: Dialog Provider Scope Fix
- [x] **Capture Bloc:** In `lib/features/booking/presentation/pages/booking_detail_page.dart` inside `_showUpdateStatusDialog`, captured `final bloc = context.read<BookingDetailBloc>();` *before* `showDialog`.
- [x] **Use Captured Bloc:** Inside `showDialog`'s `builder`, used the captured `bloc` variable to add events (e.g., `bloc.add(...)`) instead of calling `context.read<BookingDetailBloc>()` again.

## Phase 3: Verification & Cleanup
- [x] **Run Analysis:** `analyze_files` to ensure no lint errors.
- [x] **Format Code:** `dart_format`.
- [x] **Commit:** `fix(booking): history sorting and dialog provider scope`.

## Journal
- **2025-12-13**: Plan created.
- **2025-12-13**: Phase 1 (History Sorting Verification & Fix) completed:
    - Verified `getMyBookings` query already uses `.orderBy('startTime', descending: true)` for newest-first sorting.
    - Verified `BookingHistoryPage` does not reverse the `ListView`.
    - No code changes required for sorting based on current understanding. Further clarification would be needed if the user's definition of "terbalik" implies something other than oldest-first vs newest-first.
- **2025-12-13**: Phase 2 (Dialog Provider Scope Fix) completed:
    - Captured `BookingDetailBloc` instance before calling `showDialog`.
    - Used the captured `bloc` instance to dispatch events directly within the dialog, resolving `ProviderNotFoundException`.
    - Also fixed `undefined_identifier` regression in `BookingDetailPage`.
- **2025-12-13**: Phase 3 (Verification & Cleanup) completed:
    - Ran `dart fix` and `analyze_files` (no new issues, accepted existing warnings).
    - Ran `dart format` (no new issues).
    - All unit tests passed.
    - Committed changes.
