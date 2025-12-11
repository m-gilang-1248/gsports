# Implementation Plan: Profile & Logout

## Journal
- **Iteration 4 Start:** Starting implementation of Profile & Logout features.
- **Goal:** Update `ProfilePage` to display user data from `AuthBloc` and handle logout via `AuthBloc` event and `GoRouter` navigation.
- **Phase 1 Completed:** Implemented `ProfilePage` UI and logic. Verified with `profile_page_test.dart` (Widget Test). Fixed linting and formatting issues.

## Phase 1: Profile & Logout UI Implementation
- [x] Run all tests to ensure the project is in a good state.
- [x] Update `lib/features/auth/presentation/pages/profile_page.dart`.
    - [x] Import `flutter_bloc`, `go_router`, `AuthBloc`, `AuthState`, `AuthEvent`.
    - [x] Wrap content in `BlocListener<AuthBloc, AuthState>` to handle `AuthUnauthenticated` -> `context.go('/login')`.
    - [x] Wrap content in `BlocBuilder<AuthBloc, AuthState>` to get `UserEntity`.
    - [x] Implement UI layout:
        - [x] Avatar (CircleAvatar).
        - [x] Name & Email (Text).
        - [x] Member Status (Chip).
        - [x] Logout Button (ListTile/Button) triggering `LogoutRequested`.
- [x] **Verification:**
    - [x] Verify `AuthBloc` state usage (`AuthAuthenticated.user`).
    - [x] Verify `LogoutRequested` event dispatch.
- [x] **Testing (Widget):**
    - [x] Create `test/features/auth/presentation/pages/profile_page_test.dart`.
    - [x] Test rendering of user info (mocking `AuthAuthenticated` state).
    - [x] Test logout button triggers event.
- [x] Run `dart_fix`.
- [x] Run `analyze_files`.
- [x] Run tests.
- [x] Run `dart_format`.
- [x] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [x] Verify changes with `git diff`.
- [x] Commit changes: `feat: implement profile page and logout logic`.
- [ ] Hot Reload.

## Phase 2: Finalization
- [ ] Update `README.md` (if needed).
- [ ] Update `GEMINI.md` context.
- [ ] User Review.