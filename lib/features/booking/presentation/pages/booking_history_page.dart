import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/core/presentation/widgets/filters/sport_filter_row.dart';
import 'package:gsports/core/presentation/widgets/filters/time_filter_dropdown.dart';
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
          if (state.status == HistoryStatus.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
          } else if (state.status == HistoryStatus.joinSuccess) {
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
                if (state.status == HistoryStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == HistoryStatus.error) {
                  return _buildErrorState(state.message ?? 'Unknown error');
                } else if (state.status == HistoryStatus.loaded ||
                    state.status == HistoryStatus.joinSuccess) {
                  return TabBarView(
                    children: [
                      _buildBookingList(
                        _filterActiveBookings(state.bookings),
                        isHistoryTab: false,
                        state: state,
                      ),
                      _buildBookingList(
                        state.filteredHistoryBookings,
                        isHistoryTab: true,
                        state: state,
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
      final isPaidActive =
          (b.status == 'confirmed' || b.status == 'paid') &&
          b.endTime.isAfter(now);
      return isWaiting || isPaidActive;
    }).toList();

    active.sort((a, b) => a.date.compareTo(b.date));
    return active;
  }

  Widget _buildBookingList(
    List<Booking> bookings, {
    required bool isHistoryTab,
    required HistoryState state,
  }) {
    return Column(
      children: [
        if (isHistoryTab) _buildFilterSection(context, state),
        Expanded(
          child: bookings.isEmpty
              ? _buildEmptyState(
                  isHistoryTab
                      ? 'Belum ada riwayat booking.'
                      : 'Tidak ada booking yang sedang berlangsung.',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<HistoryBloc>().add(
                      FetchBookingHistory(widget.userId),
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
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
                ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context, HistoryState state) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
                TimeFilterDropdown(
                  selectedPreset: state.selectedTimePreset,
                  customDate: state.customDate,
                  onFilterChanged: (preset, date) {
                    context.read<HistoryBloc>().add(
                      UpdateBookingTimeFilter(preset: preset, customDate: date),
                    );
                  },
                ),
              ],
            ),
          ),
          SportFilterRow(
            selectedSportId: state.selectedSportId,
            onSportSelected: (sportId) {
              context.read<HistoryBloc>().add(
                UpdateBookingSportFilter(sportId),
              );
            },
          ),
          const Divider(),
        ],
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
