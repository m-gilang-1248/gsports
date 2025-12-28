import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:gsports/features/partner/booking_management/presentation/widgets/booking_order_card.dart';

class BookingAnalyticsPage extends StatelessWidget {
  const BookingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<OrderManagementBloc>()..add(FetchPartnerBookings()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Detail Pesanan'),
          backgroundColor: Colors.white,
        ),
        body: BlocBuilder<OrderManagementBloc, OrderManagementState>(
          builder: (context, state) {
            if (state is OrderManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderManagementLoaded) {
              // Show only paid/ongoing bookings as per requirement "Pesanan Berjalan"
              // Or all paid bookings? The card said "Pesanan Berjalan".
              final ongoingBookings = state.allBookings
                  .where((b) => b.status == 'paid')
                  .toList();

              if (ongoingBookings.isEmpty) {
                return const Center(child: Text('Tidak ada pesanan berjalan'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ongoingBookings.length,
                itemBuilder: (context, index) {
                  return BookingOrderCard(booking: ongoingBookings[index]);
                },
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
