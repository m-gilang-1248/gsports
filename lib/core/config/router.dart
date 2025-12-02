import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/auth/presentation/pages/login_page.dart';
import 'package:gsports/features/auth/presentation/pages/register_page.dart';
import 'package:gsports/features/auth/presentation/pages/splash_page.dart';
import 'package:gsports/features/home/presentation/pages/home_page.dart';
import 'package:gsports/features/booking/presentation/pages/booking_page.dart';
import 'package:gsports/core/utils/go_router_refresh_stream.dart'; // New import

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      GetIt.I<AuthBloc>().stream,
    ), // Added
    redirect: (context, state) {
      final authBloc = GetIt.I<AuthBloc>();
      final authState = authBloc.state;

      final bool loggedIn = authState is AuthAuthenticated;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool registering = state.matchedLocation == '/register';
      final bool splashing = state.matchedLocation == '/';

      // If we are in the middle of the app's loading sequence, let it be.
      // This is specifically for when the SplashPage is determining the initial auth state.
      if (splashing && authState is AuthInitial) {
        return null;
      }

      // If not logged in:
      // - And on the splash screen (after initial check), go to login.
      // - And trying to access protected pages (not login/register), go to login.
      if (!loggedIn) {
        if (splashing)
          return '/login'; // After splash, if still unauthenticated
        if (!loggingIn && !registering) return '/login'; // On protected page
      }

      // If logged in:
      // - And on the login or register page, go to home.
      // - And on the splash page, go to home.
      if (loggedIn) {
        if (loggingIn || registering || splashing) return '/home';
      }

      // No redirect needed for other cases
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingPage(),
      ),
    ],
  );
}
