import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/presentation/bloc/detail/booking_detail_bloc.dart';
import 'package:gsports/features/booking/presentation/widgets/payment_timer_widget.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class BookingDetailPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<BookingDetailBloc>()
            ..add(SyncBookingStatus(bookingId)), // Sync with Midtrans on open
      child: _BookingDetailView(bookingId: bookingId),
    );
  }
}

class _BookingDetailView extends StatefulWidget {
  final String bookingId;
  const _BookingDetailView({required this.bookingId});

  @override
  State<_BookingDetailView> createState() => _BookingDetailViewState();
}

class _BookingDetailViewState extends State<_BookingDetailView> {
  bool _isExpired = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: () {
              context.read<BookingDetailBloc>().add(
                SyncBookingStatus(widget.bookingId),
              );
            },
          ),
        ],
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
            final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
            final bool isHost = booking.userId == currentUserUid;

            final bool actuallyExpired =
                booking.status == 'cancelled' || _isExpired;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<BookingDetailBloc>().add(
                        SyncBookingStatus(widget.bookingId),
                      );
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (booking.status == 'waiting_payment' &&
                              !actuallyExpired) ...[
                            PaymentTimerWidget(
                              createdAt: booking.createdAt,
                              onExpired: () {
                                setState(() {
                                  _isExpired = true;
                                });
                                context.read<BookingDetailBloc>().add(
                                  CancelBookingRequested(booking.id),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildBookingInfoCard(
                            context,
                            booking,
                            actuallyExpired,
                          ),
                          const SizedBox(height: 24),
                          _buildSplitBillSection(
                            context,
                            booking,
                            isHost,
                            currentUserUid,
                          ),
                          const SizedBox(height: 24),
                          _buildParticipantsSection(
                            context,
                            booking,
                            isHost,
                            currentUserUid,
                            state.isUpdatingParticipant,
                          ),
                          const SizedBox(height: 24),
                          _buildMatchHistorySection(context, state.matches),
                        ],
                      ),
                    ),
                  ),
                ),
                if (booking.status == 'waiting_payment' && isHost)
                  _buildBottomAction(context, booking, actuallyExpired),
                if (_shouldShowScoreboard(booking))
                  _buildScoreboardAction(context, booking),
              ],
            );
          } else if (state is BookingDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<BookingDetailBloc>().add(
                      SyncBookingStatus(widget.bookingId),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Widget _buildMatchHistorySection(BuildContext context, List<MatchResult> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Pertandingan',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final match = matches[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Winner: ${match.winner}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              match.sets.map((s) => '${s.scoreA}-${s.scoreB}').join(', '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDuration(match.durationSeconds),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Duration',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowScoreboard(Booking booking) {
    final isPaid =
        booking.paymentStatus == 'paid' ||
        booking.paymentStatus == 'settlement' ||
        booking.paymentStatus == 'capture';
    final now = DateTime.now();
    final isToday =
        booking.date.year == now.year &&
        booking.date.month == now.month &&
        booking.date.day == now.day;
    return isPaid && isToday;
  }

  Widget _buildScoreboardAction(BuildContext context, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              context.push(
                '/scoreboard',
                extra: {
                  'bookingId': booking.id,
                  'sportType': booking.sportType,
                  'players': booking.participantIds,
                },
              );
            },
            icon: const Icon(Icons.scoreboard),
            label: const Text('Buka Scoreboard'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fixedSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    Booking booking,
    bool actuallyExpired,
  ) {
    // Capture the BLoC before the async gap or dialog
    final bookingBloc = context.read<BookingDetailBloc>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Batalkan Pesanan?'),
                      content: const Text(
                        'Apakah Anda yakin ingin membatalkan pesanan ini? Slot akan dibuka kembali untuk orang lain.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Tidak'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            // Use the captured bloc to avoid context issues
                            bookingBloc.add(CancelBookingRequested(booking.id));
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Ya, Batalkan'),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fixedSize: const Size.fromHeight(50),
                ),
                child: const Text('Batalkan'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: actuallyExpired
                    ? null
                    : () => _onPayPressed(context, booking),
                style: FilledButton.styleFrom(
                  backgroundColor: actuallyExpired
                      ? Colors.grey
                      : AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fixedSize: const Size.fromHeight(50),
                ),
                child: Text(
                  actuallyExpired ? 'Expired' : 'Bayar Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPayPressed(BuildContext context, Booking booking) async {
    final bookingBloc = context.read<BookingDetailBloc>();
    if (booking.midtransPaymentUrl != null) {
      await context.push<String>('/payment', extra: booking.midtransPaymentUrl);
      // When coming back, always sync status
      bookingBloc.add(SyncBookingStatus(booking.id));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Payment URL not found')),
      );
    }
  }

  Widget _buildBookingInfoCard(
    BuildContext context,
    Booking booking,
    bool actuallyExpired,
  ) {
    final dateFormat = DateFormat('EEE, d MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final int numberOfParticipants = booking.participants.length;
    final int estimatedShare = numberOfParticipants > 0
        ? booking.totalPrice ~/ numberOfParticipants
        : booking.totalPrice;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: #${booking.id}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
                _buildStatusChip(
                  booking.paymentStatus,
                  booking.status,
                  actuallyExpired,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              booking.sportType,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Venue & Court Info
            Text(
              booking.venueName ?? 'Venue #${booking.venueId}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (booking.courtName != null)
              Text(
                booking.courtName!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            if (booking.venueLocation != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.venueLocation!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Date & Time Highlight
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(booking.date),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Waktu',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${dateTimeFormat.format(booking.createdAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  currencyFormat.format(booking.totalPrice),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (booking.isSplitBill && numberOfParticipants > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimasi Patungan per orang:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    currencyFormat.format(estimatedShare),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitBillSection(
    BuildContext context,
    Booking booking,
    bool isHost,
    String? currentUserUid,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patungan (Split Bill)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (booking.splitCode == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bagikan tagihan dengan temanmu.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (isHost)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Aktifkan & Bagikan Kode'),
                        onPressed: () {
                          context.read<BookingDetailBloc>().add(
                            GenerateCodeRequested(booking.id),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(color: AppColors.secondary),
                        ),
                      ),
                    )
                  else
                    Text(
                      'Hanya host yang dapat mengaktifkan patungan.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kode Patungan:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          booking.splitCode!,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 2,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: booking.splitCode!),
                            ).then((_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kode berhasil disalin!'),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bagikan kode ini ke temanmu agar bisa bergabung.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(
    BuildContext context,
    Booking booking,
    bool isHost,
    String? currentUserUid,
    bool isUpdatingParticipant,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Peserta',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isUpdatingParticipant)
              const Center(child: CircularProgressIndicator())
            else if (booking.participants.isEmpty)
              Text(
                'Belum ada peserta yang bergabung.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: booking.participants.length,
                itemBuilder: (context, index) {
                  final participant = booking.participants[index];
                  return _buildParticipantTile(
                    context,
                    booking,
                    participant,
                    isHost,
                    currentUserUid,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantTile(
    BuildContext context,
    Booking booking,
    PaymentParticipant participant,
    bool isHost,
    String? currentUserUid,
  ) {
    final bool canEdit = isHost && (participant.uid != currentUserUid);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: participant.profileUrl != null
                ? NetworkImage(participant.profileUrl!)
                : null,
            child: participant.profileUrl == null
                ? Text(participant.name[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  participant.status == 'host' ? 'Host' : 'Peserta',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          _buildPaymentStatusChip(participant.paymentStatusToHost),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showUpdateStatusDialog(
                context,
                booking.id,
                participant.uid!,
              ),
            ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    String bookingId,
    String participantUid,
  ) {
    final bloc = context.read<BookingDetailBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tandai Lunas'),
              onTap: () {
                bloc.add(
                  UpdateParticipantPaymentStatus(
                    bookingId: bookingId,
                    participantUid: participantUid,
                    newStatus: 'paid',
                  ),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Tandai Belum Bayar'),
              onTap: () {
                bloc.add(
                  UpdateParticipantPaymentStatus(
                    bookingId: bookingId,
                    participantUid: participantUid,
                    newStatus: 'pending',
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    Color color = status == 'paid' ? Colors.green : Colors.orange;
    String label = status == 'paid' ? 'Lunas' : 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  Widget _buildStatusChip(
    String paymentStatus,
    String bookingStatus,
    bool isTimerExpired,
  ) {
    Color color;
    String label;
    if (bookingStatus == 'cancelled' || isTimerExpired) {
      color = AppColors.error;
      label = 'Cancelled';
    } else if (paymentStatus == 'paid' ||
        paymentStatus == 'settlement' ||
        paymentStatus == 'capture') {
      color = AppColors.success;
      label = 'Success';
    } else {
      color = Colors.orange;
      label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
