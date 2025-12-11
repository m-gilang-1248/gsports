# Modification Design: Fix MainPage Test

## 1. Overview
The `test/core/presentation/pages/main_page_test.dart` is failing because `MainPage` now integrates `BookingHistoryPage`, which introduces dependencies on `FirebaseAuth` and `HistoryBloc` that are not mocked in the test environment. This modification aims to fix the test suite.

## 2. Problem Analysis
*   **Error:** `[core/no-app] No Firebase App '[DEFAULT]' has been created` and `GetIt` lookup failures.
*   **Cause:**
    *   `BookingHistoryPage` calls `FirebaseAuth.instance`.
    *   `BookingHistoryPage` calls `GetIt.I<HistoryBloc>()`.
    *   The test setup only mocks `VenueBloc`.

## 3. Solution Design

### A. Test Setup Update
1.  **Firebase Mocks:**
    *   Use `setupFirebaseAuthMocks()` from `firebase_auth_mocks` in `setUpAll`.
    *   Register a mock `FirebaseAuth` instance in `GetIt` if needed, or rely on `firebase_auth_mocks` global override if applicable.
    *   *Correction:* `BookingHistoryPage` accesses `FirebaseAuth.instance` directly. `firebase_auth_mocks` with `setupFirebaseAuthMocks()` handles the platform channel interception, so direct access works and returns the mock user.

2.  **Dependency Injection:**
    *   Create `MockHistoryBloc`.
    *   Register `MockHistoryBloc` in `GetIt` inside `setUp`.
    *   Stub `HistoryBloc` states (Initial, Loading, Loaded).

3.  **Expectation Updates:**
    *   Replace outdated `find.text('My Bookings - Coming Soon')`.
    *   Use `find.text('My Bookings')` (AppBar title) or `find.byType(BookingHistoryPage)`.

### B. Mock Classes
```dart
class MockHistoryBloc extends Mock implements HistoryBloc {}
class MockHistoryState extends Mock implements HistoryState {}
class FakeHistoryEvent extends Fake implements HistoryEvent {}
class FakeHistoryState extends Fake implements HistoryState {}
```

## 4. Implementation Details
*   **File:** `test/core/presentation/pages/main_page_test.dart`
*   **Imports:** Add `firebase_auth`, `firebase_auth_mocks`, `firebase_core`.

## 5. Verification
*   Run `flutter test test/core/presentation/pages/main_page_test.dart`.
