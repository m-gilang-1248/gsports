import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:intl/intl.dart';

class RevenueAnalyticsPage extends StatelessWidget {
  const RevenueAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<OrderManagementBloc>()..add(FetchPartnerBookings()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Detail Pendapatan'),
          backgroundColor: Colors.white,
        ),
        body: BlocBuilder<OrderManagementBloc, OrderManagementState>(
          builder: (context, state) {
            if (state is OrderManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderManagementLoaded) {
              // Filter for revenue (paid bookings)
              // Group by Day? For now just list them with total.
              final revenueBookings = state.allBookings
                  .where((b) => b.status == 'paid')
                  .toList();

              if (revenueBookings.isEmpty) {
                return const Center(child: Text('Belum ada pendapatan'));
              }

              int totalRevenue = revenueBookings.fold(
                0,
                (sum, item) => sum + item.totalPrice,
              );

              final currencyFormat = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: Column(
                      children: [
                        const Text(
                          'Total Pendapatan Akumulatif',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(totalRevenue),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: revenueBookings.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final booking = revenueBookings[index];
                        return ListTile(
                          title: Text(
                            booking.venueName ?? 'Venue',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat(
                              'd MMM yyyy, HH:mm',
                            ).format(booking.createdAt),
                          ),
                          trailing: Text(
                            currencyFormat.format(booking.totalPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is OrderManagementFailure) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
