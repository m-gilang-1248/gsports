import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/features/auth/domain/entities/user_entity.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_event.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/profile/domain/entities/user_stats.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_event.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_state.dart';
import 'package:gsports/features/profile/presentation/pages/profile_page.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockScoreboardRepository extends Mock implements ScoreboardRepository {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

class FakeProfileEvent extends Fake implements ProfileEvent {}

class FakeProfileState extends Fake implements ProfileState {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProfileBloc mockProfileBloc;
  late MockScoreboardRepository mockScoreboardRepository;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
    registerFallbackValue(FakeProfileEvent());
    registerFallbackValue(FakeProfileState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProfileBloc = MockProfileBloc();
    mockScoreboardRepository = MockScoreboardRepository();

    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});

    when(() => mockProfileBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockProfileBloc.close()).thenAnswer((_) async {});
    when(() => mockProfileBloc.add(any())).thenReturn(null);

    // Register in GetIt
    final sl = GetIt.instance;
    if (!sl.isRegistered<ProfileBloc>()) {
      sl.registerFactory<ProfileBloc>(() => mockProfileBloc);
    }
    if (!sl.isRegistered<ScoreboardRepository>()) {
      sl.registerLazySingleton<ScoreboardRepository>(
        () => mockScoreboardRepository,
      );
    }

    // Default mock for matches
    when(
      () => mockScoreboardRepository.getMatchesByUser(any()),
    ).thenAnswer((_) async => const Right([]));
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: const MaterialApp(home: ProfilePage()),
    );
  }

  testWidgets('renders user info and stats when loaded', (tester) async {
    final user = UserEntity(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'user',
      tier: 'free',
      createdAt: DateTime.now(),
    );
    const stats = UserStats(matchesPlayed: 10, matchesWon: 5, winRate: 50);

    when(() => mockProfileBloc.state).thenReturn(
      ProfileLoaded(user: user, stats: stats),
    );
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // For FutureBuilder

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // Matches
    expect(find.text('5'), findsOneWidget); // Won
    expect(find.text('50%'), findsOneWidget); // Win Rate
  });

  testWidgets('triggers LogoutRequested when logout button is tapped', (
    tester,
  ) async {
    final user = UserEntity(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'user',
      tier: 'free',
      createdAt: DateTime.now(),
    );
    const stats = UserStats(matchesPlayed: 0, matchesWon: 0, winRate: 0);

    when(() => mockProfileBloc.state).thenReturn(
      ProfileLoaded(user: user, stats: stats),
    );
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user));
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    final logoutFinder = find.text('Logout');
    await tester.ensureVisible(logoutFinder);
    await tester.tap(logoutFinder);
    await tester.pump();

    verify(() => mockAuthBloc.add(LogoutRequested())).called(1);
  });
}