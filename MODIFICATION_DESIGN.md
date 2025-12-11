# Modification Design: Profile & Logout (Iteration 4)

## 1. Overview
This iteration focuses on implementing the functionality of the User Profile page and the Logout mechanism. We will leverage the existing `AuthBloc` to display user information and handle the logout process, adhering to the Clean Architecture principles.

## 2. Problem Analysis
*   **Goal:** Make the `ProfilePage` functional by displaying user details and enabling logout.
*   **Current State:** `ProfilePage` is a placeholder. `AuthBloc` exists and manages authentication state.
*   **Data Source:** User data should be sourced from `AuthBloc` state (`AuthAuthenticated`), not directly from `FirebaseAuth` SDK, to decouple the UI from the data source.
*   **Navigation:** `GoRouter` redirect is disabled. Navigation upon logout must be handled explicitly via `BlocListener`.

## 3. Solution Design

### A. Presentation Layer (UI)
*   **Page:** `ProfilePage` (`lib/features/auth/presentation/pages/profile_page.dart`).
*   **State Management:**
    *   `BlocBuilder<AuthBloc, AuthState>`: To rebuild the UI when user data is available (`AuthAuthenticated`).
    *   `BlocListener<AuthBloc, AuthState>`: To listen for `AuthUnauthenticated` state and navigate to `/login`.
*   **Components:**
    *   **Header:**
        *   `CircleAvatar`: Displays user initial (e.g., "J" for John Doe) if photo URL is missing.
        *   `Text`: User Name (`displayName`) and Email (`email`).
        *   `Chip`: "Free Member" (Hardcoded for MVP).
    *   **Menu (Optional for this specific task but good for structure):**
        *   ListTiles for future features (e.g., "Edit Profile").
    *   **Logout Button:**
        *   Red text/icon.
        *   Triggers `LogoutRequested` event.

### B. Logic Flow
1.  **Load:** `ProfilePage` is displayed. `AuthBloc` should already be in `AuthAuthenticated` state (since we are in the shell).
2.  **Display:** UI extracts `UserEntity` from `AuthAuthenticated` state.
3.  **Logout:**
    *   User taps "Logout".
    *   UI dispatches `LogoutRequested`.
    *   `AuthBloc` calls `LogoutUser` use case.
    *   `AuthBloc` emits `AuthUnauthenticated`.
    *   `BlocListener` detects state change -> `context.go('/login')`.

## 4. Detailed Component Design

### ProfilePage Structure
```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              final user = state.user;
              return Column(
                children: [
                  // Avatar & Info
                  CircleAvatar(
                    radius: 40,
                    child: Text(user.displayName?[0].toUpperCase() ?? 'U'),
                  ),
                  Text(user.displayName ?? 'No Name'),
                  Text(user.email ?? 'No Email'),
                  const Chip(label: Text('Free Member')),
                  
                  const Spacer(),
                  
                  // Logout Button
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator()); // Should rarely happen in shell
          },
        ),
      ),
    );
  }
}
```

## 5. Alternatives Considered
*   **Redirect in Router:** Setting `redirect` in `GoRouter` to check `AuthBloc` state.
    *   *Decision:* Rejected. Previous iteration experience suggests direct navigation is more reliable for this specific setup and avoids circular dependency issues or router complexity for now.
*   **Direct FirebaseAuth Access:** Using `FirebaseAuth.instance.currentUser`.
    *   *Decision:* Rejected. Violates Clean Architecture (Presentation layer talking to Data layer/SDK directly). Using `AuthBloc` is the correct architectural choice.

## 6. References
*   [Flutter BlocListener](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html)
*   [GoRouter Navigation](https://pub.dev/packages/go_router)