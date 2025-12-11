# Implementation Plan: Fix MainPage Test

## Phase 1: Fix Test Setup
- [ ] Update `test/core/presentation/pages/main_page_test.dart`.
    - [ ] Add imports: `firebase_auth`, `firebase_auth_mocks`.
    - [ ] Create `MockHistoryBloc` and fake events/states.
    - [ ] In `setUpAll`: Call `TestWidgetsFlutterBinding.ensureInitialized()` and `setupFirebaseAuthMocks()`.
    - [ ] In `setUp`:
        - [ ] Create mocks (`VenueBloc`, `HistoryBloc`).
        - [ ] Reset and register mocks in `GetIt`.
        - [ ] Mock `FirebaseAuth` user (anonymous or normal) using `MockUser` and `MockFirebaseAuth`.
        - [ ] Stub Bloc streams/states.
    - [ ] Update test expectations (look for "My Bookings" title).
- [ ] Run `flutter test test/core/presentation/pages/main_page_test.dart` to verify pass.
- [ ] Commit changes.