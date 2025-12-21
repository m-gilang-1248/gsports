import 'package:flutter/material.dart';
import '../../../features/auth/presentation/pages/profile_page.dart';
import '../../../features/booking/presentation/pages/booking_history_page.dart';
import '../../../features/home/presentation/pages/home_page.dart';
// import '../../../features/venue/presentation/bloc/venue_bloc.dart'; // Removed
// import '../../../injection_container.dart'; // Removed if not used

class MainPage extends StatefulWidget {
  final List<Widget>? pages; // For testing
  const MainPage({super.key, this.pages});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Generate pages dynamically to pass state
    final pages = widget.pages ??
        [
          const HomePage(),
          BookingHistoryPage(isVisible: _currentIndex == 1),
          const ProfilePage(),
        ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
