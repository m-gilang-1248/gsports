import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gsports/features/auth/presentation/pages/login_page.dart';
import 'package:gsports/features/auth/presentation/pages/register_page.dart';
import 'package:gsports/features/auth/presentation/pages/splash_page.dart';
import 'package:gsports/features/home/presentation/pages/home_page.dart';
import 'package:gsports/features/booking/presentation/pages/booking_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
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
