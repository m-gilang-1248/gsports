# Modification Design: Fix Venue List Loading Logic

## 1. Overview
This modification addresses a bug where the Venue List gets stuck in a loading state or refetches unnecessarily when navigating back to the Home page. We will implement state preservation for the `HomePage` and refine the data fetching logic to avoid redundant calls.

## 2. Problem Analysis
*   **Bug:** Venue List reloads/flickers or gets stuck when returning to Home.
*   **Cause:**
    *   `HomePage` might be rebuilding and triggering fetches (though currently it doesn't trigger in `initState`, `main.dart` does).
    *   If `VenueBloc` emits `VenueLoading` due to some other event (like detail fetch sharing the same bloc state? No, detail fetch emits `VenueLoading` too!).
    *   **CRITICAL ISSUE:** `VenueBloc` handles *both* list and detail fetching. When `VenueDetailPage` triggers `VenueFetchDetailRequested`, it emits `VenueLoading` then `VenueDetailLoaded`.
    *   When returning to `HomePage`, `BlocBuilder` sees `VenueDetailLoaded` (or `VenueLoading` if it didn't finish?). `HomePage`'s `buildWhen` filters:
        ```dart
        buildWhen: (previous, current) =>
            current is VenueListLoaded ||
            current is VenueLoading ||
            current is VenueError,
        ```
    *   If state is `VenueDetailLoaded`, `buildWhen` returns `false` (presumably, unless it falls through). If it returns false, UI doesn't update? No, if it returns false, it keeps previous state.
    *   **BUT:** If `VenueBloc` was in `VenueDetailLoaded` state, and we come back to Home, we want to see the list. The list data is likely GONE from the state because `VenueDetailLoaded` replaces `VenueListLoaded`.
    *   **Solution:** We need to persist the list data or separate the BLoCs. Since refactoring to separate BLoCs is a larger task (though cleaner), we can try to re-fetch list when returning to Home *if* the state is not `VenueListLoaded`.
    *   **Refinement:** `HomePage`'s `initState` should check: If state is NOT `VenueListLoaded`, fetch list. This handles the case where `VenueDetailLoaded` overwrote the state.

## 3. Solution Design

### A. Main Entry Point (`lib/main.dart`)
*   Remove the cascade `..add(VenueFetchListRequested())` from the provider. `HomePage` will handle the initial fetch.

### B. Home Page (`lib/features/home/presentation/pages/home_page.dart`)
*   **Mixin:** Add `AutomaticKeepAliveClientMixin` to `_HomePageState`.
*   **KeepAlive:** Override `wantKeepAlive` to return `true`.
*   **InitState:**
    ```dart
    @override
    void initState() {
      super.initState();
      final bloc = context.read<VenueBloc>();
      // If state is NOT loaded list (e.g. initial, or detail loaded), fetch list.
      if (bloc.state is! VenueListLoaded) {
        bloc.add(VenueFetchListRequested());
      }
    }
    ```
*   **Build:** Call `super.build(context)`.

## 4. Implementation Details

### `HomePage` Refactor
```dart
class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<VenueBloc>();
    if (bloc.state is! VenueListLoaded) {
      bloc.add(VenueFetchListRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Critical
    return Scaffold(...);
  }
}
```

## 5. Verification
*   **Scenario 1:** App Launch -> Home loads list.
*   **Scenario 2:** Home -> Click Venue -> Detail Page (State becomes `VenueDetailLoaded`) -> Back to Home.
    *   `initState` won't run again if `KeepAlive` works? **Wait.**
    *   If `KeepAlive` is active, `initState` runs ONCE.
    *   When coming back from Detail Page, `HomePage` is still alive. It won't trigger `initState`.
    *   **ISSUE:** The state in Bloc is `VenueDetailLoaded`. The `BlocBuilder` in `HomePage` needs to react to this? No, `buildWhen` ignores `VenueDetailLoaded`. So it continues showing whatever it showed before.
    *   **BUT:** If `VenueDetailLoaded` replaced `VenueListLoaded`, does `BlocBuilder` hold onto the previous widget tree? Yes, if `buildWhen` is false.
    *   **HOWEVER:** If we navigate away and back, and `VenueBloc` state changed to `VenueDetailLoaded`, `HomePage` might still show the list *visually* because it wasn't rebuilt.
    *   **Risk:** If `HomePage` *does* rebuild (e.g. keyboard open/close, or parent rebuild), it will check `state`. `state` is `VenueDetailLoaded`. `buildWhen` filters it out?
    *   If `buildWhen` filters it out, `builder` isn't called. Safe.
    *   **WHAT IF:** User refreshes? `RefreshIndicator` triggers `VenueFetchListRequested`. State becomes `VenueLoading` -> `VenueListLoaded`. Correct.

    *   **Revisiting the "Stuck Loading" bug report:** "VenueList Stuck Loading saat Navigasi Kembali".
        *   This suggests `VenueLoading` *was* emitted (maybe by Detail fetch start) and `HomePage` listened to it.
        *   `VenueBloc` emits `VenueLoading` at start of `_onFetchDetail`.
        *   `HomePage` listens to `VenueLoading`. So it shows spinner.
        *   Then `VenueBloc` emits `VenueDetailLoaded`.
        *   `HomePage` `buildWhen` checks `VenueDetailLoaded`. It returns `false` (assuming check is `is VenueListLoaded || is VenueLoading || is VenueError`).
        *   So `HomePage` stays stuck on the previous valid state for it, which was `VenueLoading`. **BINGO.**

    *   **Fix Strategy Update:**
        *   We need `HomePage` to *ignore* `VenueLoading` if it's caused by Detail Fetch? We can't distinguish them easily in the simple Bloc.
        *   **Better Fix:** When returning to Home (or when `MainPage` tab is switched to Home), we should ensure state is List.
        *   Since `HomePage` is kept alive, we can't rely on `initState`.
        *   But `MainPage` manages tabs.
        *   **Alternative:** In `VenueBloc`, separate `VenueListLoading` and `VenueDetailLoading`? Or make `VenueDetailLoaded` extend `VenueState` but `HomePage` needs to handle it?
        *   If `HomePage` sees `VenueDetailLoaded`, it should probably trigger a list fetch? No, that causes loop.
        *   **Quick Fix:**
            1.  Change `VenueLoading` to be specific? No, too much boilerplate.
            2.  Change `HomePage` `buildWhen`. If `state` is `VenueDetailLoaded`, trigger fetch? You can't trigger event in `build`.
            3.  **Use `FocusDetector` or similar?** No.
            4.  **Refactor Bloc (Best):** Separate states logic. But constraints say "Modify Home Page".
            5.  **Workaround:** `HomePage` should *re-fetch* list when it becomes visible if state is wrong.
            6.  **Simpler Workaround:** In `VenueBloc`, do NOT emit `VenueLoading` for detail fetch if we want to avoid disturbing Home? No, Detail page needs loading.

    *   **Proposed Solution (Refined):**
        *   In `HomePage`, wrap body in a generic listener/watcher?
        *   Actually, if `KeepAlive` is on, `HomePage` stays mounted.
        *   When we navigate to Detail, we push a new route. `HomePage` is in the background.
        *   `VenueBloc` updates to `Loading` -> `DetailLoaded`.
        *   `HomePage` updates to `Loading` (because it listens to `VenueLoading`).
        *   `HomePage` ignores `DetailLoaded`.
        *   Result: `HomePage` shows Loading.
        *   When we pop Detail, `HomePage` is revealed. It is still showing Loading.
        *   **Fix:** `HomePage` needs to fetch list when it realizes it's visible and state is wrong.
        *   **Implementation:** Use `RouteAware`? Or simpler: In `build`, if `state` is `VenueDetailLoaded`, return ... wait, we can't fetch in build.
        *   **Strategy:** In `MainPage`, when switching *to* Home tab, we can check. But Detail Page is pushed *over* MainPage.
        *   **The "Stuck" fix:** If `HomePage` is `Stateful`, use `didPopNext` (via `RouteAware`) to refetch list?
        *   **Easier:** When `VenueDetailPage` pops, can we signal?
        *   **Even Easier:** In `VenueBloc`, when `VenueFetchDetailRequested` happens, do *not* emit generic `VenueLoading`? Create `VenueDetailLoading`.
        *   **Let's modify `VenueBloc` slightly:** Add `VenueDetailLoading` and `VenueListLoading`? Or just `VenueLoading` is fine but `HomePage` should only listen if it's relevant? Hard to know intent.

    *   **Decision:**
        1.  In `VenueBloc`, rename `VenueLoading` to `VenueListLoading` (for list fetch) and `VenueDetailLoading` (for detail fetch).
        2.  Update `HomePage` to listen only to `VenueListLoading`.
        3.  Update `VenueDetailPage` to listen to `VenueDetailLoading`.
        4.  This isolates the loading states.
        5.  Also, when `VenueDetailLoaded` is emitted, `HomePage` still needs to know how to get back to List.
        6.  Actually, if `HomePage` ignores Detail states, it will stay on whatever it had *before* Detail fetch started.
            *   Before Detail fetch: `VenueListLoaded`.
            *   Detail fetch starts: Emits `VenueDetailLoading`. `HomePage` ignores. Stays `VenueListLoaded`.
            *   Detail fetch ends: Emits `VenueDetailLoaded`. `HomePage` ignores. Stays `VenueListLoaded`.
            *   **Perfect.** The list remains visible in the background.
        7.  BUT: navigating back, the state is `VenueDetailLoaded`. If user pulls to refresh, it works.
        8.  What if user expects list to update? It won't auto-update. That's fine for now.

    *   **Revised Plan:**
        1.  Modify `venue_state.dart`: Split `VenueLoading` into `VenueListLoading` and `VenueDetailLoading`. (Or add a type/flag to `VenueLoading`).
        2.  Modify `venue_bloc.dart`: Emit appropriate loading state.
        3.  Modify `HomePage`: `buildWhen` checks for `VenueListLoading`.
        4.  Modify `VenueDetailPage`: Checks for `VenueDetailLoading`.
        5.  Refactor `HomePage` with `KeepAlive` and `initState` logic (as originally requested) to handle *initial* load properly.

## 6. Verification
*   Home -> Detail -> Back: Home should show List (not spinner).