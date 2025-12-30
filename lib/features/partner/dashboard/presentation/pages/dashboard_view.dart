import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:gsports/features/partner/dashboard/presentation/bloc/partner_dashboard_bloc.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PartnerDashboardBloc>().add(FetchPartnerDashboardStats());
        context.read<OrderManagementBloc>().add(FetchPartnerBookings());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            const Text(
              'Status Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildOrderStatusRow(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Partner';
        String? photoUrl;

        if (state is AuthAuthenticated) {
          name = state.user.displayName;
          photoUrl = state.user.photoUrl;
        }

        return Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return BlocBuilder<PartnerDashboardBloc, PartnerDashboardState>(
      builder: (context, state) {
        int totalBookings = 0;
        int totalRevenue = 0;

        if (state is PartnerDashboardLoaded) {
          totalBookings = state.stats.totalBookings;
          totalRevenue = state.stats.totalRevenue;
        }

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
            _buildCard(
              title: 'Pesanan Berjalan',
              value: totalBookings.toString(),
              icon: Icons.confirmation_number_outlined,
              color: AppColors.secondary,
              onTap: () {
                context.push('/partner/booking-analytics');
              },
            ),
            _buildCard(
              title: 'Pendapatan',
              value: currencyFormat.format(totalRevenue),
              icon: Icons.monetization_on_outlined,
              color: AppColors.success,
              onTap: () {
                context.push('/partner/revenue-analytics');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                    fontSize: 16, // Adjusted size to fit currency
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
      ),
    );
  }

  Widget _buildOrderStatusRow(BuildContext context) {
    return BlocBuilder<OrderManagementBloc, OrderManagementState>(
      builder: (context, state) {
        int pendingCount = 0;
        int todayCount = 0;
        int ongoingCount = 0;

        if (state is OrderManagementLoaded) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          pendingCount = state.pendingBookings.length;

          todayCount = state.upcomingBookings.where((b) {
            final date = DateTime(b.date.year, b.date.month, b.date.day);
            return date.isAtSameMomentAs(today);
          }).length;

          // Ongoing: StartTime <= Now <= EndTime AND Status == Paid
          ongoingCount = state.allBookings.where((b) {
            return b.status == 'paid' &&
                now.isAfter(b.startTime) &&
                now.isBefore(b.endTime);
          }).length;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem(
                context,
                icon: Icons.assignment_late_outlined,
                label: 'Perlu\nKonfirmasi',
                count: pendingCount,
                onTap: () {
                  context.push('/partner/orders');
                },
              ),
              _buildStatusItem(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Jadwal\nHari Ini',
                count: todayCount,
                onTap: () {
                  context.push('/partner/orders');
                },
              ),
              _buildStatusItem(
                context,
                icon: Icons.sports_tennis_outlined,
                label: 'Sedang\nMain',
                count: ongoingCount,
                onTap: () {
                  context.push('/partner/orders');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 28, color: Colors.grey[700]),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
