import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/auth/presentation/pages/login_page.dart';
import 'package:gsports/features/auth/presentation/pages/register_page.dart'; // New import
import 'package:gsports/features/auth/presentation/pages/splash_page.dart';
import 'package:gsports/features/home/presentation/pages/home_page.dart';
import 'package:gsports/features/booking/presentation/pages/booking_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // We need to access the AuthBloc. We can do this via GetIt since it's registered as a singleton.
      // Note: This pattern assumes AuthBloc is already initialized by the time redirect is called.
      // For more complex scenarios, consider GoRouterRefreshStream.
      final authBloc = GetIt.I<AuthBloc>();
      final authState = authBloc.state;

      final bool loggedIn = authState is AuthAuthenticated;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool registering = state.matchedLocation == '/register';
      final bool splashing = state.matchedLocation == '/';

      // If the app is still splashing, let it proceed to splash page.
      if (splashing) return null;

      // If not logged in, but trying to access protected pages (not login/register), go to login.
      if (!loggedIn && !(loggingIn || registering)) {
        return '/login';
      }
      // If logged in, but trying to access login or register page, go to home.
      if (loggedIn && (loggingIn || registering)) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ), // New route
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingPage(),
      ),
    ],
  );
}
