# Implementation Plan: Profile & Logout

## Journal
- **Iteration 4 Start:** Starting implementation of Profile & Logout features.
- **Goal:** Update `ProfilePage` to display user data from `AuthBloc` and handle logout via `AuthBloc` event and `GoRouter` navigation.

## Phase 1: Profile & Logout UI Implementation
- [ ] Run all tests to ensure the project is in a good state.
- [ ] Update `lib/features/auth/presentation/pages/profile_page.dart`.
    - [ ] Import `flutter_bloc`, `go_router`, `AuthBloc`, `AuthState`, `AuthEvent`.
    - [ ] Wrap content in `BlocListener<AuthBloc, AuthState>` to handle `AuthUnauthenticated` -> `context.go('/login')`.
    - [ ] Wrap content in `BlocBuilder<AuthBloc, AuthState>` to get `UserEntity`.
    - [ ] Implement UI layout:
        - [ ] Avatar (CircleAvatar).
        - [ ] Name & Email (Text).
        - [ ] Member Status (Chip).
        - [ ] Logout Button (ListTile/Button) triggering `LogoutRequested`.
- [ ] **Verification:**
    - [ ] Verify `AuthBloc` state usage (`AuthAuthenticated.user`).
    - [ ] Verify `LogoutRequested` event dispatch.
- [ ] **Testing (Widget):**
    - [ ] Create `test/features/auth/presentation/pages/profile_page_test.dart`.
    - [ ] Test rendering of user info (mocking `AuthAuthenticated` state).
    - [ ] Test logout button triggers event.
- [ ] Run `dart_fix`.
- [ ] Run `analyze_files`.
- [ ] Run tests.
- [ ] Run `dart_format`.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Verify changes with `git diff`.
- [ ] Commit changes: `feat: implement profile page and logout logic`.
- [ ] Hot Reload.

## Phase 2: Finalization
- [ ] Update `README.md` (if needed).
- [ ] Update `GEMINI.md` context.
- [ ] User Review.
