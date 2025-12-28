import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:gsports/features/partner/dashboard/presentation/bloc/partner_dashboard_bloc.dart';
import 'package:gsports/features/partner/dashboard/presentation/pages/dashboard_view.dart';
import 'package:gsports/features/partner/dashboard/presentation/pages/orders_view.dart';
import 'package:gsports/features/partner/dashboard/presentation/pages/profile_view.dart';
import 'package:gsports/features/partner/dashboard/presentation/pages/venues_view.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/venue_management_bloc.dart';

class PartnerMainPage extends StatelessWidget {
  const PartnerMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetIt.I<PartnerDashboardBloc>()..add(FetchPartnerDashboardStats()),
        ),
        BlocProvider(
          create: (context) =>
              GetIt.I<VenueManagementBloc>()..add(FetchMyVenues()),
        ),
        BlocProvider(
          create: (context) =>
              GetIt.I<OrderManagementBloc>()..add(FetchPartnerBookings()),
        ),
      ],
      child: const _PartnerMainPageView(),
    );
  }
}

class _PartnerMainPageView extends StatefulWidget {
  const _PartnerMainPageView();

  @override
  State<_PartnerMainPageView> createState() => _PartnerMainPageViewState();
}

class _PartnerMainPageViewState extends State<_PartnerMainPageView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    VenuesView(),
    OrdersView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stadium_outlined),
              activeIcon: Icon(Icons.stadium),
              label: 'Venue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    String title;
    List<Widget>? actions;

    switch (_selectedIndex) {
      case 0: // Dashboard
        title = 'Dashboard Mitra';
        actions = [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Input Pesanan Manual',
            onPressed: () => context.push('/partner/manual-booking'),
          ),
        ];
        break;
      case 1: // Venues
        title = 'Kelola Venue';
        actions = [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Venue',
            onPressed: () => context.push('/add-venue'),
          ),
        ];
        break;
      case 2: // Orders
        title = 'Kelola Pesanan';
        actions = [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Input Pesanan Manual',
            onPressed: () => context.push('/partner/manual-booking'),
          ),
        ];
        break;
      case 3: // Profile
        title = 'Profil Saya';
        actions = [];
        break;
      default:
        title = 'Gsports Partner';
    }

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      actions: actions,
    );
  }
}
