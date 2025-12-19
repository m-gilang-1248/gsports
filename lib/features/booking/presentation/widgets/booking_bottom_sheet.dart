import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

class BookingBottomSheet extends StatelessWidget {
  final Venue venue;
  final Court court;
  final DateTime date;
  final DateTime startTime;

  const BookingBottomSheet({
    super.key,
    required this.venue,
    required this.court,
    required this.date,
    required this.startTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // MVP: Fixed 1 hour duration
    final endTime = startTime.add(const Duration(hours: 1));
    final durationHours = 1;
    final totalPrice = court.hourlyPrice * durationHours;

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Venue Info
          Text(
            'Konfirmasi Booking',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            context,
            icon: Icons.stadium_outlined,
            label: 'Venue',
            value: venue.name,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.sports_tennis_outlined,
            label: 'Lapangan',
            value: court.name,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Waktu',
            value:
                '${DateFormat('d MMM yyyy').format(date)}, ${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
          ),
          const Divider(height: 32),

          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              Text(
                currencyFormat.format(totalPrice),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pay Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  // Should be handled by auth guard, but safety check
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan login terlebih dahulu'),
                    ),
                  );
                  return;
                }

                final booking = Booking(
                  id: DateTime.now().millisecondsSinceEpoch
                      .toString(), // Temp ID
                  userId: user.uid,
                  venueId: venue.id,
                  courtId: court.id,
                  sportType: court.sportType,
                  date: DateTime(date.year, date.month, date.day),
                  startTime: startTime,
                  endTime: endTime,
                  durationHours: durationHours,
                  totalPrice: totalPrice,
                  status: 'waiting_payment',
                  paymentStatus: 'unpaid',
                  participants: [
                    PaymentParticipant(
                      uid: user.uid,
                      name: user.displayName ?? 'User',
                      status: 'host',
                      paymentStatusToHost: 'paid', // Host pays directly
                      profileUrl: user.photoURL,
                    ),
                  ],
                  participantIds: [user.uid],
                  createdAt: DateTime.now(),
                );

                context.read<BookingBloc>().add(BookingCreated(booking));
                Navigator.pop(context); // Close sheet
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Bayar & Konfirmasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
