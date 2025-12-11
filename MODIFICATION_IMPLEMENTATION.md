# Implementation Plan: Fix Venue List Loading Logic

## Journal
- **Phase 1 Start:** Fixing VenueList stuck loading bug.
- **Analysis:** Detected that shared `VenueLoading` state causes `HomePage` to get stuck when `VenueDetailLoaded` is ignored. Decided to split loading states.
- **Phase 1 Completed:** Refactored `VenueState` to have `VenueListLoading` and `VenueDetailLoading`. Updated `VenueBloc` to emit specific loading states. Updated `HomePage` to listen to `VenueListLoading` and implement `AutomaticKeepAliveClientMixin` with smart fetch logic. Updated `VenueDetailPage` to listen to `VenueDetailLoading`. Removed auto-fetch from `main.dart`. Verified tests pass.

## Phase 1: Bloc & State Refactoring
- [x] Run all tests to ensure the project is in a good state.
- [x] **Refactor Venue State (`lib/features/venue/presentation/bloc/venue_state.dart`):**
    - [x] Rename `VenueLoading` to `VenueListLoading` (or add `VenueDetailLoading`).
    - [x] Ensure `VenueState` can distinguish context.
- [x] **Refactor Venue Bloc (`lib/features/venue/presentation/bloc/venue_bloc.dart`):**
    - [x] `_onFetchList`: Emit `VenueListLoading`.
    - [x] `_onFetchDetail`: Emit `VenueDetailLoading`.
- [x] **Update Pages:**
    - [x] `HomePage`: Update `buildWhen` and `builder` to handle `VenueListLoading` (ignore `VenueDetailLoading`).
    - [x] `VenueDetailPage`: Update `builder` to handle `VenueDetailLoading`.
- [x] **Refactor HomePage (`lib/features/home/presentation/pages/home_page.dart`):**
    - [x] Implement `AutomaticKeepAliveClientMixin`.
    - [x] `initState`: Fetch only if state is not `VenueListLoaded` (and not loading list).
- [x] **Clean Main (`lib/main.dart`):**
    - [x] Remove cascade `..add(VenueFetchListRequested())`.
- [x] **Verification:**
    - [x] Manual Test: Home -> Detail -> Back.
    - [x] Run tests (Update unit tests for Bloc if states changed).
- [x] Run `dart_fix`.
- [x] Run `analyze_files`.
- [x] Run tests.
- [x] Run `dart_format`.
- [x] Verify changes with `git diff`.
- [x] Commit changes: `fix: resolve venue list stuck loading by separating loading states`.
- [x] Hot Reload.

## Phase 2: Finalization
- [ ] Update `GEMINI.md` context.
- [ ] User Review.