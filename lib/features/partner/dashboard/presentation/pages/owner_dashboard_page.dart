import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_event.dart';
import 'package:gsports/features/partner/dashboard/presentation/bloc/partner_dashboard_bloc.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/venue_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:intl/intl.dart';

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetIt.I<PartnerDashboardBloc>()
                ..add(FetchPartnerDashboardStats()),
        ),
        BlocProvider(
          create: (context) =>
              GetIt.I<VenueManagementBloc>()..add(FetchMyVenues()),
        ),
      ],
      child: const _OwnerDashboardView(),
    );
  }
}

class _OwnerDashboardView extends StatelessWidget {
  const _OwnerDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Dashboard'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/add-venue');
          if (result == true && context.mounted) {
            context.read<PartnerDashboardBloc>().add(
              FetchPartnerDashboardStats(),
            );
            context.read<VenueManagementBloc>().add(FetchMyVenues());
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Venue', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PartnerDashboardBloc>().add(
            FetchPartnerDashboardStats(),
          );
          context.read<VenueManagementBloc>().add(FetchMyVenues());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STATS SECTION
              BlocBuilder<PartnerDashboardBloc, PartnerDashboardState>(
                builder: (context, state) {
                  if (state is PartnerDashboardLoaded) {
                    return _buildStatsGrid(
                      state.stats.totalBookings,
                      state.stats.totalRevenue,
                    );
                  }
                  return _buildStatsGrid(0, 0);
                },
              ),
              const SizedBox(height: 24),

              // 2. MY VENUES SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Venues',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.push('/manage-venues'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlocBuilder<VenueManagementBloc, VenueManagementState>(
                builder: (context, state) {
                  if (state is VenueManagementLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is VenueManagementSuccess) {
                    if (state.venues.isEmpty) {
                      return _buildEmptyState('No venues added yet');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.venues.take(3).length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildVenueCompactCard(
                          context,
                          state.venues[index],
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // 3. RECENT TRANSACTIONS
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              BlocBuilder<PartnerDashboardBloc, PartnerDashboardState>(
                builder: (context, state) {
                  if (state is PartnerDashboardLoaded) {
                    return _buildRecentTransactions(
                      state.stats.recentTransactions,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int totalBookings, int totalRevenue) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Bookings',
          totalBookings.toString(),
          Icons.calendar_today,
          AppColors.secondary,
        ),
        _buildStatCard(
          'Total Revenue',
          currencyFormat.format(totalRevenue),
          Icons.monetization_on,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCompactCard(BuildContext context, Venue venue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () =>
            context.push('/venue-courts/${venue.id}', extra: venue.name),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: venue.photos.isNotEmpty
                  ? Image.network(venue.photos[0], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
            ),
          ),
          title: Text(
            venue.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${venue.city} • ${venue.facilities.length} Facilities',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState('No recent transactions');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = transactions[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.receipt,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              booking.venueName ?? 'Unknown Venue',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              DateFormat('d MMM yyyy, HH:mm').format(booking.startTime),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(booking.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  booking.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: booking.paymentStatus == 'paid'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
