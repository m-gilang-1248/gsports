import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
import 'package:gsports/features/partner/dashboard/presentation/pages/owner_dashboard_page.dart';
import 'package:gsports/features/partner/venue_management/presentation/pages/manage_venues_page.dart';
import 'package:gsports/features/partner/venue_management/presentation/pages/add_edit_venue_page.dart';
import 'package:gsports/features/partner/venue_management/presentation/pages/venue_courts_page.dart';
import 'package:gsports/features/partner/venue_management/presentation/pages/add_edit_court_page.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/venue_management_bloc.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/court_management_bloc.dart';
import 'package:gsports/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/scoreboard/presentation/pages/scoreboard_page.dart';
import 'package:gsports/features/scoreboard/presentation/pages/match_recap_page.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
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
        return '/home';
      }

      // Role Guard for Partner Routes
      final isPartnerRoute =
          path.startsWith('/owner') ||
          path.startsWith('/manage-venues') ||
          path.startsWith('/add-venue') ||
          path.startsWith('/edit-venue') ||
          path.startsWith('/venue-courts');

      if (isLoggedIn && isPartnerRoute) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final role = doc.data()?['role'] as String?;
          if (role != 'mitra') {
            return '/home';
          }
        } catch (e) {
          return '/home';
        }
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
        path: '/manage-venues',
        builder: (context, state) => const ManageVenuesPage(),
      ),
      GoRoute(
        path: '/add-venue',
        builder: (context, state) => BlocProvider(
          create: (context) => GetIt.I<VenueManagementBloc>(),
          child: const AddEditVenuePage(),
        ),
      ),
      GoRoute(
        path: '/edit-venue',
        builder: (context, state) {
          final venue = state.extra as Venue;
          return BlocProvider(
            create: (context) => GetIt.I<VenueManagementBloc>(),
            child: AddEditVenuePage(venue: venue),
          );
        },
      ),
      GoRoute(
        path: '/venue-courts/:venueId',
        builder: (context, state) {
          final venueName = state.extra as String? ?? 'Venue';
          return VenueCourtsPage(
            venueId: state.pathParameters['venueId']!,
            venueName: venueName,
          );
        },
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => BlocProvider(
              create: (context) => GetIt.I<CourtManagementBloc>(),
              child: AddEditCourtPage(
                venueId: state.pathParameters['venueId']!,
              ),
            ),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final court = state.extra as Court;
              return BlocProvider(
                create: (context) => GetIt.I<CourtManagementBloc>(),
                child: AddEditCourtPage(
                  venueId: state.pathParameters['venueId']!,
                  court: court,
                ),
              );
            },
          ),
        ],
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
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/scoreboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ScoreboardPage(
            bookingId: extra['bookingId'] as String,
            sportType: extra['sportType'] as String,
            players: extra['players'] as List<String>,
            teamA: extra['teamA'] as List<String>,
            teamB: extra['teamB'] as List<String>,
            teamAName: extra['teamAName'] as String,
            teamBName: extra['teamBName'] as String,
            playerNames: extra['playerNames'] as Map<String, String>,
            venueName: extra['venueName'] as String?,
            courtName: extra['courtName'] as String?,
            startTime: extra['startTime'] as DateTime?,
            endTime: extra['endTime'] as DateTime?,
          );
        },
      ),
      GoRoute(
        path: '/match-recap',
        builder: (context, state) {
          final match = state.extra as MatchResult;
          return MatchRecapPage(match: match);
        },
      ),
    ],
  );
}
