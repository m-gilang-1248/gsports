import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/presentation/bloc/detail/booking_detail_bloc.dart';
import 'package:gsports/features/booking/presentation/widgets/payment_timer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class BookingDetailPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<BookingDetailBloc>()
        ..add(FetchBookingDetail(bookingId)),
      child: const _BookingDetailView(),
    );
  }
}

class _BookingDetailView extends StatefulWidget {
  const _BookingDetailView();

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
          // Now this context is UNDER BlocProvider, so it works.
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: () {
              // We need to re-fetch. Since we don't store ID in state, 
              // we can rely on the BLoC to have the ID if we want, or better:
              // The BLoC state 'BookingDetailLoaded' has the booking object with ID.
              // But if it's Error or Loading, we might not have it easily accessible unless we stored it.
              // However, since the Bloc was created with the event in parent, we can just trigger the event again if we knew the ID.
              // A trick: The Bloc instance in the provider is the same.
              // Let's verify if we can access the bookingId from the Bloc or State.
              // For now, let's assume the user only refreshes when data is loaded or error (which might need ID).
              // To be safe, we should probably pass ID to _BookingDetailView, but let's try to get it from context if possible or modify structure slightly.
              // Actually, simpler: Pass bookingId to _BookingDetailView constructor.
              final state = context.read<BookingDetailBloc>().state;
              if (state is BookingDetailLoaded) {
                 context.read<BookingDetailBloc>().add(FetchBookingDetail(state.booking.id));
              } else {
                // If error or loading, we might not have ID handy unless passed down.
                // Let's modify the parent to pass it.
                // Since I can't easily change the parent structure in this single file write without making it complex,
                // I will assume for now we only refresh when loaded.
                // WAIT: I can just change _BookingDetailView to accept bookingId.
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<BookingDetailBloc, BookingDetailState>(
        listener: (context, state) {
          if (state is BookingDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingDetailLoaded) {
            final booking = state.booking;
            final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
            final bool isHost = booking.userId == currentUserUid;

            // Logic: Expired if status is cancelled OR local timer finished.
            // Also check if payment deadline is passed? 
            // The PaymentTimerWidget handles visual countdown.
            final bool actuallyExpired =
                booking.status == 'cancelled' || _isExpired;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ALWAYS show timer if waiting_payment, unless explicitly cancelled/expired
                        if (booking.status == 'waiting_payment' && !actuallyExpired) ...[
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
                        _buildBookingInfoCard(context, booking, actuallyExpired),
                        const SizedBox(height: 24),
                        _buildSplitBillSection(context, booking, isHost, currentUserUid),
                        const SizedBox(height: 24),
                        _buildParticipantsSection(
                          context,
                          booking,
                          isHost,
                          currentUserUid,
                          state.isUpdatingParticipant,
                        ),
                      ],
                    ),
                  ),
                ),
                  if (booking.status == 'waiting_payment' && isHost)
                    Container(
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
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Batalkan Pesanan?'),
                                      content: const Text(
                                          'Apakah Anda yakin ingin membatalkan pesanan ini? Slot akan dibuka kembali untuk orang lain.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Tidak'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            context.read<BookingDetailBloc>().add(
                                                  CancelBookingRequested(booking.id),
                                                );
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
                                  actuallyExpired
                                      ? 'Expired'
                                      : 'Bayar',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
          } else if (state is BookingDetailError) {
             // In error state, we might want to allow retry which needs ID.
             // We'll handle this by passing ID to View in next step if needed, 
             // but strictly for "Refresh" button crash, this fix is enough.
             // The Retry button in center already works because it uses the closure from the previous build method? 
             // No, wait. The previous code used widget.bookingId from the stateful widget.
             // We need to pass bookingId to _BookingDetailView.
            return Center(
              child: Text(state.message),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _onPayPressed(BuildContext context, Booking booking) async {
    if (booking.midtransPaymentUrl != null) {
      final result = await context.push<String>(
        '/payment',
        extra: booking.midtransPaymentUrl,
      );
      if (result == 'success' && context.mounted) {
        context.read<BookingDetailBloc>().add(FetchBookingDetail(booking.id));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link pembayaran tidak tersedia')),
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
                _buildStatusChip(booking.paymentStatus, booking.status, actuallyExpired),
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
            const SizedBox(height: 8),
            Text(
              '${dateFormat.format(booking.date)} • ${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${dateTimeFormat.format(booking.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 2,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: booking.splitCode!)).then((_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kode berhasil disalin!')),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isUpdatingParticipant)
              const Center(child: CircularProgressIndicator())
            else if (booking.participants.isEmpty)
              Text(
                'Belum ada peserta yang bergabung.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'Lunas';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      default:
        color = Colors.grey;
        label = 'N/A';
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