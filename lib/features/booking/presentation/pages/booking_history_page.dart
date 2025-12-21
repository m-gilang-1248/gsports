import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/features/booking/presentation/bloc/history/history_bloc.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/presentation/widgets/custom_button.dart';
import 'package:gsports/features/booking/presentation/widgets/booking_history_card.dart';

class BookingHistoryPage extends StatelessWidget {
  final bool isVisible;

  const BookingHistoryPage({super.key, this.isVisible = false});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Login untuk mengakses riwayat booking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan masuk untuk melihat status pembayaran dan detail lapangan yang telah Anda pesan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Masuk Sekarang',
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) =>
          GetIt.I<HistoryBloc>()..add(FetchBookingHistory(userId)),
      child: _BookingHistoryContent(userId: userId, isVisible: isVisible),
    );
  }
}

class _BookingHistoryContent extends StatefulWidget {
  final String userId;
  final bool isVisible;

  const _BookingHistoryContent({required this.userId, required this.isVisible});

  @override
  State<_BookingHistoryContent> createState() => _BookingHistoryContentState();
}

class _BookingHistoryContentState extends State<_BookingHistoryContent> {
  @override
  void didUpdateWidget(covariant _BookingHistoryContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      context.read<HistoryBloc>().add(FetchBookingHistory(widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocConsumer<HistoryBloc, HistoryState>(
        listener: (context, state) async {
          if (state is HistoryError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is HistoryJoinSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil bergabung ke booking!')),
            );
            await GoRouter.of(
              context,
            ).push('/booking-detail/${state.bookingId}');
            if (context.mounted) {
              context.read<HistoryBloc>().add(
                FetchBookingHistory(widget.userId),
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Bookings'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Berlangsung'),
                  Tab(text: 'Riwayat'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<HistoryBloc>().add(
                      FetchBookingHistory(widget.userId),
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showJoinDialog(context, widget.userId),
              icon: const Icon(Icons.group_add),
              label: const Text('Join Booking'),
            ),
            body: Builder(
              builder: (context) {
                if (state is HistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HistoryError) {
                  return _buildErrorState(state.message);
                } else if (state is HistoryLoaded) {
                  return TabBarView(
                    children: [
                      _buildBookingList(
                        _filterActiveBookings(state.bookings),
                        isHistoryTab: false,
                      ),
                      _buildBookingList(
                        _filterHistoryBookings(state.bookings),
                        isHistoryTab: true,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  List<Booking> _filterActiveBookings(List<Booking> bookings) {
    final now = DateTime.now();
    final active = bookings.where((b) {
      final isWaiting = b.status == 'waiting_payment';
      final isPaidFuture =
          (b.status == 'confirmed' || b.status == 'paid') &&
          b.date.isAfter(now);
      return isWaiting || isPaidFuture;
    }).toList();

    // Sort Ascending (Soonest first)
    active.sort((a, b) => a.date.compareTo(b.date));
    return active;
  }

  List<Booking> _filterHistoryBookings(List<Booking> bookings) {
    final now = DateTime.now();
    final history = bookings.where((b) {
      final isCancelled = b.status == 'cancelled' || b.status == 'expired';
      final isPaidPast =
          (b.status == 'confirmed' || b.status == 'paid') &&
          (b.date.isBefore(now) || b.date.isAtSameMomentAs(now));
      return isCancelled || isPaidPast;
    }).toList();

    // Sort Descending (Newest past first)
    history.sort((a, b) => b.date.compareTo(a.date));
    return history;
  }

  Widget _buildBookingList(
    List<Booking> bookings, {
    required bool isHistoryTab,
  }) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        isHistoryTab
            ? 'Belum ada riwayat booking.'
            : 'Tidak ada booking yang sedang berlangsung.',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(FetchBookingHistory(widget.userId));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return BookingHistoryCard(
            booking: bookings[index],
            onReturn: () {
              context.read<HistoryBloc>().add(
                FetchBookingHistory(widget.userId),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<HistoryBloc>().add(
                FetchBookingHistory(widget.userId),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context, String userId) {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Join Booking'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(hintText: 'Enter Booking Code'),
          ),
          actions: [
            TextButton(
              onPressed: () => GoRouter.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String code = codeController.text.trim();
                if (code.isNotEmpty) {
                  GoRouter.of(dialogContext).pop();
                  context.read<HistoryBloc>().add(
                    JoinBookingRequested(code, userId),
                  );
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
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
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
