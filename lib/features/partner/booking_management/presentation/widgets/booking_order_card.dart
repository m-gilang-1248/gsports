import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';

class BookingOrderCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingOrderCard({super.key, required this.booking, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final statusColor = _getStatusColor(booking.status);
    final statusText = _getStatusText(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Status Strip
              Container(width: 6, color: statusColor),

              // 2. Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ROW 1: Avatar + Username | Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildUserRow(booking)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ROW 2: Sport Type (Bold) + Court Name
                      RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  AppConstants.getSportIcon(booking.sportType),
                                  size: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${AppConstants.getSportName(booking.sportType).toUpperCase()} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: booking.courtName ?? 'Lapangan',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // ROW 3: Date + Time | Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  Icons.calendar_today_outlined,
                                  DateFormat(
                                    'd MMMM yyyy',
                                    'id_ID',
                                  ).format(booking.date),
                                ),
                                const SizedBox(height: 4),
                                _buildInfoRow(
                                  Icons.access_time,
                                  '${DateFormat('HH:mm').format(booking.startTime)} - ${DateFormat('HH:mm').format(booking.endTime)}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            currencyFormat.format(booking.totalPrice),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
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
    );
  }

  Widget _buildUserRow(Booking booking) {
    final participant = booking.participants.isNotEmpty
        ? booking.participants.first
        : null;
    final name = participant?.name ?? 'Guest';
    final profileUrl = participant?.profileUrl;

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
          child: profileUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'G',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.success;
      case 'waiting_payment':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textTertiary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'LUNAS / JADWAL';
      case 'waiting_payment':
        return 'MENUNGGU PEMBAYARAN';
      case 'cancelled':
        return 'DIBATALKAN';
      case 'completed':
        return 'SELESAI';
      default:
        return status.toUpperCase();
    }
  }
}
