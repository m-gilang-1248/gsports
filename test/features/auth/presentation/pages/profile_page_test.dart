import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsports/features/auth/domain/entities/user_entity.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_event.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/auth/presentation/pages/profile_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: const MaterialApp(
        home: ProfilePage(),
      ),
    );
  }

  testWidgets('renders user info when authenticated', (tester) async {
    final user = UserEntity(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'user',
      tier: 'free',
      createdAt: DateTime.now(),
    );
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Free Member'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('triggers LogoutRequested when logout button is tapped', (tester) async {
    final user = UserEntity(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'user',
      tier: 'free',
      createdAt: DateTime.now(),
    );
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user));
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Logout'));
    await tester.pump();

    verify(() => mockAuthBloc.add(LogoutRequested())).called(1);
  });
}
