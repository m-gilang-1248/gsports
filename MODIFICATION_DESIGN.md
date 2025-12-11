# Modification Design: Fix Venue Provider Scope & History Interactions

## 1. Overview
This modification addresses a critical bug where `VenueDetailPage` throws a `ProviderNotFoundException` because `VenueBloc` was provided at the `MainPage` level, which is not in the ancestor chain of `VenueDetailPage` (pushed via `GoRouter` outside the shell). We will hoist the `VenueBloc` provider to `main.dart`. Additionally, we will add interaction feedback to the `BookingHistoryCard`.

## 2. Problem Analysis
*   **Bug:** `VenueDetailPage` cannot find `VenueBloc`.
*   **Cause:** `VenueBloc` is provided in `MainPage`. `VenueDetailPage` is a sibling route to `MainPage` (or pushed on top of root navigator), not a child of `MainPage`.
*   **Solution:** Provide `VenueBloc` at the top level (`main.dart`), similar to `AuthBloc`.

## 3. Solution Design

### A. Provider Refactoring
*   **`lib/main.dart`:**
    *   Add `BlocProvider<VenueBloc>` to the `MultiBlocProvider`.
    *   Ensure it initializes with `VenueFetchListRequested`.
*   **`lib/core/presentation/pages/main_page.dart`:**
    *   Remove `BlocProvider<VenueBloc>`.
    *   `MainPage` will now consume `VenueBloc` provided by `main.dart`.

### B. Booking History UI Updates
*   **`BookingHistoryCard` (`lib/features/booking/presentation/pages/booking_history_page.dart`):**
    *   Wrap `Card` with `InkWell` or add `onTap`.
    *   Show `SnackBar` with message "Fitur Detail/Split Bill segera hadir".

## 4. Implementation Details

### `main.dart`
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (context) => GetIt.I<AuthBloc>()),
    BlocProvider<VenueBloc>(create: (context) => GetIt.I<VenueBloc>()..add(VenueFetchListRequested())),
  ],
  // ...
)
```

### `MainPage`
```dart
@override
Widget build(BuildContext context) {
  // Removed BlocProvider wrapper
  return Scaffold(...)
}
```

### `BookingHistoryPage`
```dart
GestureDetector(
  onTap: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Detail/Split Bill segera hadir')),
    );
  },
  child: Card(...),
)
```

## 5. Alternatives Considered
*   **ShellRoute:** Using `ShellRoute` in `GoRouter` would keep `MainPage` as a wrapper for all routes, potentially solving this if `VenueDetailPage` was a child route. However, `VenueDetailPage` usually sits *on top* of the bottom bar, so it shouldn't be inside the shell. Hoisting the provider is the standard Flutter solution for global state.

## 6. Verification
*   Manual test: Click a venue card -> No crash.
*   Manual test: Click a booking history card -> SnackBar appears.
