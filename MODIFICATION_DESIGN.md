# Modification Design: Navigation Shell & Main Page

## 1. Overview
This modification establishes the core navigation structure of the Gsports application. We will implement a `MainPage` that serves as the "Shell" for the authenticated user experience, providing persistent navigation via a `BottomNavigationBar`. Additionally, we will refactor the routing configuration to support this hierarchy and ensure `VenueBloc` state is preserved across tab switches.

## 2. Problem Analysis
*   **Navigation Structure:** Currently, the app navigates directly to `HomePage`. There is no mechanism to switch between major features (Home, Bookings, Profile) without pushing new routes, which is inefficient and bad UX for a main app structure.
*   **State Loss:** `VenueBloc` is likely provided inside `HomePage` or a specific route. Navigating away and back might reset the state (e.g., loaded venues, scroll position) if not handled correctly.
*   **Scalability:** We need a central place to manage global authenticated UI elements (like the bottom bar).

## 3. Solution Design

### A. MainPage Implementation
We will create `lib/core/presentation/pages/main_page.dart`.
*   **Type:** `StatefulWidget`
*   **Components:**
    *   `Scaffold`: The root visual structure.
    *   `BottomNavigationBar`:
        *   Item 0: Home (Icon: `Icons.home_outlined` / `Icons.home`)
        *   Item 1: My Bookings (Icon: `Icons.calendar_today_outlined` / `Icons.calendar_today`)
        *   Item 2: Profile (Icon: `Icons.person_outline` / `Icons.person`)
    *   `Body`: We will use `IndexedStack` to preserve the state of each page when switching tabs. This is crucial for keeping the `VenueList` scroll position and data intact.

### B. Routing Refactoring (`router.dart`)
*   **Current:** `/home` -> `HomePage`
*   **New:** `/home` -> `MainPage`
*   **Hierarchy:** `HomePage`, `MyBookingsPage`, and `ProfilePage` will be instantiated *within* `MainPage`'s `IndexedStack`, not as separate top-level `GoRoute` entries (unless we switched to `ShellRoute`, but the requirement specifies managing index in `StatefulWidget`, favoring the `IndexedStack` approach).

### C. Dependency Injection (VenueBloc)
To ensure `VenueBloc` remains active while the user switches tabs (e.g., checks bookings and comes back to home), we will provide it at the **MainPage level** or higher.
*   **Plan:** Wrap the `Scaffold` or `IndexedStack` of `MainPage` with `BlocProvider<VenueBloc>`.
*   **Benefit:** The Bloc is created when `MainPage` initializes and disposes only when user logs out or leaves `MainPage`.

### D. Placeholder Pages
Since the prompt specifically asks *not* to build the content of My Bookings/Profile yet:
*   Create `lib/features/booking/presentation/pages/my_bookings_page.dart` (Scaffold with "Coming Soon" text).
*   Create `lib/features/profile/presentation/pages/profile_page.dart` (Scaffold with "Coming Soon" text).

## 4. Detailed Component Design

### MainPage Widget
```dart
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  // ...
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MyBookingsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VenueBloc>()..add(GetVenuesEvent()), // Move provider here
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
```

## 5. Alternatives Considered
*   **GoRouter ShellRoute:** This is robust for deep linking (e.g., `/home/details`, `/profile/settings`). However, for a simple 3-tab structure where we explicitly want to manage state/index and keep pages alive easily, `IndexedStack` is a simpler, proven solution for this phase. We can migrate to `ShellRoute` later if deep linking requirements become complex.
*   **PageStorage:** Alternative to `IndexedStack` for state preservation, but `IndexedStack` is more straightforward for a fixed number of tabs.

## 6. References
*   [Flutter BottomNavigationBar Documentation](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html)
*   [Flutter IndexedStack Documentation](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)
