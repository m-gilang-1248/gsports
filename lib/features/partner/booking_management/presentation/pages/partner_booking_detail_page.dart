import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/presentation/bloc/detail/booking_detail_bloc.dart';

class PartnerBookingDetailPage extends StatelessWidget {
  final String bookingId;

  const PartnerBookingDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<BookingDetailBloc>()..add(FetchBookingDetail(bookingId)),
      child: _PartnerBookingDetailView(bookingId: bookingId),
    );
  }
}

class _PartnerBookingDetailView extends StatelessWidget {
  final String bookingId;
  const _PartnerBookingDetailView({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.white,
      ),
      body: BlocConsumer<BookingDetailBloc, BookingDetailState>(
        listener: (context, state) {
          if (state is BookingDetailError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is BookingDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingDetailLoaded) {
            final booking = state.booking;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderStatus(booking),
                        const SizedBox(height: 16),
                        _buildOrderMetadata(booking),
                        const SizedBox(height: 16),
                        _buildUserSection(booking),
                        const SizedBox(height: 16),
                        _buildBookingInfoCard(context, booking),
                        const SizedBox(height: 16),
                        _buildPaymentSummary(context, booking),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(context, booking),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderMetadata(Booking booking) {
    final createdFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    // Use midtransOrderId for display if available (looks more professional), else use ID
    final displayId = booking.midtransOrderId ?? booking.id;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kode Pesanan',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SelectableText(
                displayId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Waktu Pemesanan',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                createdFormat.format(booking.createdAt),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatus(Booking booking) {
    Color color;
    String text;
    IconData icon;

    switch (booking.status) {
      case 'paid':
        color = AppColors.success;
        text = 'Pesanan Diterima (Lunas)';
        icon = Icons.check_circle;
        break;
      case 'waiting_payment':
        color = AppColors.warning;
        text = 'Menunggu Konfirmasi';
        icon = Icons.access_time_filled;
        break;
      case 'cancelled':
        color = AppColors.error;
        text = 'Dibatalkan';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = booking.status.toUpperCase();
        icon = Icons.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection(Booking booking) {
    PaymentParticipant host;
    if (booking.participants.any((p) => p.status == 'host')) {
      host = booking.participants.firstWhere((p) => p.status == 'host');
    } else {
      host = booking.participants.first;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: host.profileUrl != null
                ? NetworkImage(host.profileUrl!)
                : null,
            child: host.profileUrl == null
                ? Text(
                  host.name.isNotEmpty ? host.name[0].toUpperCase() : 'G',
                )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Pemesan (Host)',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard(BuildContext context, Booking booking) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Lapangan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 24),
          _buildDetailItem(
            icon: Icons.stadium,
            label: 'Venue',
            value: booking.venueName ?? '-',
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.sports_tennis,
            label: 'Lapangan',
            value: booking.courtName ?? '-',
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: AppConstants.getSportIcon(booking.sportType),
            label: 'Tipe Olahraga',
            value: AppConstants.getSportName(booking.sportType).toUpperCase(),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.calendar_today,
            label: 'Tanggal Main',
            value: dateFormat.format(booking.date),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.access_time,
            label: 'Jam Main',
            value:
                '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.timer_outlined,
            label: 'Durasi',
            value: '${booking.durationHours} Jam',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildPaymentSummary(BuildContext context, Booking booking) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            currencyFormat.format(booking.totalPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Booking booking) {
    if (booking.status == 'cancelled' || booking.status == 'completed') {
      return const SizedBox.shrink();
    }

    final isManualBooking =
        booking.midtransOrderId?.startsWith('MANUAL') ?? false;
    final bloc = context.read<BookingDetailBloc>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Tombol Tolak / Batal
            Expanded(
              child: OutlinedButton(
                onPressed: () => _confirmAction(
                  context,
                  'Batalkan Pesanan',
                  'Apakah Anda yakin ingin membatalkan pesanan ini? Slot akan terbuka kembali.',
                  () {
                    bloc.add(
                      UpdateBookingStatusRequested(
                        bookingId: booking.id,
                        status: 'cancelled',
                      ),
                    );
                  },
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Tolak / Batal'),
              ),
            ),
            // Tombol Terima / Konfirmasi (Hanya jika belum paid DAN bukan manual booking)
            if (booking.status != 'paid' && !isManualBooking) ...[
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmAction(
                    context,
                    'Konfirmasi Pembayaran',
                    'Pastikan Anda sudah menerima pembayaran (Tunai/Transfer Manual). Lanjutkan?',
                    () {
                      bloc.add(
                        UpdateBookingStatusRequested(
                          bookingId: booking.id,
                          status: 'paid',
                        ),
                      );
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Terima / Lunas'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );
  }
}
