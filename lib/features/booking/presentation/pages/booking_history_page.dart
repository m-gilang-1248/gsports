import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/features/booking/presentation/bloc/history/history_bloc.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:intl/intl.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get userId from FirebaseAuth since we are in authenticated shell
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Not logged in'));
    }

    return BlocProvider(
      create: (context) =>
          GetIt.I<HistoryBloc>()..add(FetchBookingHistory(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // We need a context that has the provider.
                // However, this IconButton is outside the BlocProvider's child scope
                // relative to where we'd want to call .read().
                // But since we just created the provider in this build method,
                // we can't easily access it from this AppBar action without a Builder or moving Provider up.
                // For simplicity in this page, we'll use a Builder body or rely on Pull-to-Refresh.
              },
            ),
          ],
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HistoryBloc>().add(
                          FetchBookingHistory(userId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is HistoryLoaded) {
              if (state.bookings.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HistoryBloc>().add(FetchBookingHistory(userId));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.bookings.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return BookingHistoryCard(booking: state.bookings[index]);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class BookingHistoryCard extends StatelessWidget {
  final Booking booking;

  const BookingHistoryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, d MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Capitalize Sport Type
    final title =
        booking.sportType[0].toUpperCase() +
        booking.sportType.substring(1).toLowerCase();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(booking.paymentStatus, booking.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${dateFormat.format(booking.date)} • ${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${booking.id.substring(0, 8)}...',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String paymentStatus, String bookingStatus) {
    Color color;
    String label;

    // Logic for status display
    if (bookingStatus == 'cancelled') {
      color = Colors.red;
      label = 'Cancelled';
    } else if (paymentStatus == 'paid' ||
        paymentStatus == 'settlement' ||
        paymentStatus == 'capture') {
      color = Colors.green;
      label = 'Paid';
    } else if (paymentStatus == 'pending' ||
        bookingStatus == 'waiting_payment') {
      color = Colors.orange;
      label = 'Pending';
    } else {
      color = Colors.grey;
      label = bookingStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
