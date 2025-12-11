import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/core/presentation/pages/main_page.dart';
import 'package:gsports/features/venue/presentation/bloc/venue_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockVenueBloc extends Mock implements VenueBloc {}
class MockVenueEvent extends Mock implements VenueEvent {}
class MockVenueState extends Mock implements VenueState {}
class FakeVenueEvent extends Fake implements VenueEvent {}
class FakeVenueState extends Fake implements VenueState {}

void main() {
  late MockVenueBloc mockVenueBloc;

  setUpAll(() {
    registerFallbackValue(FakeVenueEvent());
    registerFallbackValue(FakeVenueState());
  });

  setUp(() {
    mockVenueBloc = MockVenueBloc();
    final getIt = GetIt.instance;
    getIt.reset(); // Clear all

    // Register mocks
    getIt.registerFactory<VenueBloc>(() => mockVenueBloc);

    // Stub VenueBloc
    when(() => mockVenueBloc.state).thenReturn(VenueInitial());
    when(() => mockVenueBloc.stream).thenAnswer((_) => Stream.value(VenueInitial()));
    when(() => mockVenueBloc.close()).thenAnswer((_) async {});
    when(() => mockVenueBloc.add(any())).thenReturn(null);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('MainPage renders and navigates tabs', (tester) async {
    // Inject dummy pages to avoid Firebase/Bloc dependencies of real pages
    final dummyPages = [
      const Center(child: Text('Home Page Dummy')),
      const Center(child: Text('Bookings Page Dummy')),
      const Center(child: Text('Profile Page Dummy')),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MainPage(pages: dummyPages),
      ),
    );

    // Verify initial state (Home tab)
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.text('Home Page Dummy'), findsOneWidget);

    // Tap on Bookings tab
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    // Verify Bookings page content
    expect(find.text('Bookings Page Dummy'), findsOneWidget);

    // Tap on Profile tab
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify Profile page content
    expect(find.text('Profile Page Dummy'), findsOneWidget);
  });
}
