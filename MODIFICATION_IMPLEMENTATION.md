# Implementation Plan: Fix Venue List Loading Logic

## Journal
- **Phase 1 Start:** Fixing VenueList stuck loading bug.
- **Analysis:** Detected that shared `VenueLoading` state causes `HomePage` to get stuck when `VenueDetailLoaded` is ignored. Decided to split loading states.

## Phase 1: Bloc & State Refactoring
- [ ] Run all tests to ensure the project is in a good state.
- [ ] **Refactor Venue State (`lib/features/venue/presentation/bloc/venue_state.dart`):**
    - [ ] Rename `VenueLoading` to `VenueListLoading` (or add `VenueDetailLoading`).
    - [ ] Ensure `VenueState` can distinguish context.
- [ ] **Refactor Venue Bloc (`lib/features/venue/presentation/bloc/venue_bloc.dart`):**
    - [ ] `_onFetchList`: Emit `VenueListLoading`.
    - [ ] `_onFetchDetail`: Emit `VenueDetailLoading`.
- [ ] **Update Pages:**
    - [ ] `HomePage`: Update `buildWhen` and `builder` to handle `VenueListLoading` (ignore `VenueDetailLoading`).
    - [ ] `VenueDetailPage`: Update `builder` to handle `VenueDetailLoading`.
- [ ] **Refactor HomePage (`lib/features/home/presentation/pages/home_page.dart`):**
    - [ ] Implement `AutomaticKeepAliveClientMixin`.
    - [ ] `initState`: Fetch only if state is not `VenueListLoaded` (and not loading list).
- [ ] **Clean Main (`lib/main.dart`):**
    - [ ] Remove cascade `..add(VenueFetchListRequested())`.
- [ ] **Verification:**
    - [ ] Manual Test: Home -> Detail -> Back.
    - [ ] Run tests (Update unit tests for Bloc if states changed).
- [ ] Run `dart_fix`.
- [ ] Run `analyze_files`.
- [ ] Run tests.
- [ ] Run `dart_format`.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Verify changes with `git diff`.
- [ ] Commit changes: `fix: resolve venue list stuck loading by separating loading states`.
- [ ] Hot Reload.

## Phase 2: Finalization
- [ ] Update `GEMINI.md` context.
- [ ] User Review.
