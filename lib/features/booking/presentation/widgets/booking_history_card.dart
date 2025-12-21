import 'package:flutter/material.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class BookingHistoryCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onReturn;

  const BookingHistoryCard({super.key, required this.booking, this.onReturn});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Capitalize Sport Type
    final sportName =
        booking.sportType[0].toUpperCase() +
        booking.sportType.substring(1).toLowerCase();

    // Status & Color Logic
    Color statusColor;
    String statusLabel;

    // Check cancellation/expiry first
    if (booking.status == 'cancelled' || booking.status == 'expired') {
      statusColor = AppColors.error;
      statusLabel = 'Cancelled';
    } else if (booking.status == 'waiting_payment' ||
        booking.paymentStatus == 'pending') {
      statusColor = AppColors.warning; // Orange
      statusLabel = 'Pending';
    } else if (booking.paymentStatus == 'paid' ||
        booking.paymentStatus == 'settlement' ||
        booking.paymentStatus == 'capture') {
      statusColor = AppColors.success;
      statusLabel = 'Paid';
    } else {
      statusColor = Colors.grey;
      statusLabel = booking.status;
    }

    return InkWell(
      onTap: () async {
        await GoRouter.of(context).push('/booking-detail/${booking.id}');
        onReturn?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Color Strip Indicator
                Container(width: 6, color: statusColor),

                // 2. Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Icon + Sport Name + Status Chip
                        Row(
                          children: [
                            Icon(
                              AppConstants.getSportIcon(booking.sportType),
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sportName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            // Optional small chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Body: Venue Name + Date/Time
                        Text(
                          'Venue #${booking.venueId.substring(0, 5)}...', // Ideally use venueName if available in Entity
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dateFormat.format(booking.date)} • ${timeFormat.format(booking.startTime)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Footer: Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(booking.totalPrice),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
