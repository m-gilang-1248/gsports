import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gsports/features/auth/presentation/pages/login_page.dart';
import 'package:gsports/features/auth/presentation/pages/register_page.dart';
import 'package:gsports/features/auth/presentation/pages/splash_page.dart';
import 'package:gsports/core/presentation/pages/main_page.dart';
import 'package:gsports/features/booking/presentation/pages/booking_page.dart';
import 'package:gsports/features/home/presentation/pages/search_page.dart';
import 'package:gsports/features/venue/presentation/pages/venue_detail_page.dart';
import 'package:gsports/features/payment/presentation/pages/payment_page.dart';
import 'package:gsports/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:gsports/features/partner/presentation/pages/owner_dashboard_page.dart';

import 'package:gsports/features/scoreboard/presentation/pages/scoreboard_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final path = state.uri.path;

      // Whitelist Strategy
      final publicRoutes = ['/login', '/register', '/home', '/'];
      final isPublic = publicRoutes.contains(path) || path.startsWith('/venue');

      // Guard: Redirect guest to login if accessing protected route
      if (!isLoggedIn && !isPublic) {
        return '/login';
      }

      // Auth Skip: Redirect authenticated user away from auth pages
      if (isLoggedIn && (path == '/login' || path == '/register')) {
        // Here we could ideally check roles, but for now we default to home
        // Role check would usually require a Bloc state or Firestore fetch
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainPage()),
      GoRoute(
        path: '/owner-dashboard',
        builder: (context, state) => const OwnerDashboardPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return SearchPage(initialCategory: category);
        },
      ),
      GoRoute(
        path: '/venue/:id',
        builder: (context, state) =>
            VenueDetailPage(venueId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingPage(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final paymentUrl = state.extra as String;
          return PaymentPage(paymentUrl: paymentUrl);
        },
      ),
      GoRoute(
        path: '/booking-detail/:id',
        builder: (context, state) =>
            BookingDetailPage(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/scoreboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ScoreboardPage(
            bookingId: extra['bookingId'] as String,
            sportType: extra['sportType'] as String,
          );
        },
      ),
    ],
  );
}
