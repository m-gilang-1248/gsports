import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:gsports/features/booking/presentation/widgets/booking_bottom_sheet.dart';
import 'package:gsports/features/booking/presentation/widgets/booking_time_slot_grid.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/presentation/bloc/venue_bloc.dart';
import 'package:gsports/injection_container.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VenueDetailPage extends StatefulWidget {
  final String venueId;

  const VenueDetailPage({super.key, required this.venueId});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<VenueBloc>().add(VenueFetchDetailRequested(widget.venueId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookingBloc>(),
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking berhasil!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/home');
          } else if (state is BookingPaymentPageReady) {
            _handlePaymentNavigation(context, state);
          } else if (state is BookingPaidSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pembayaran untuk booking ${state.bookingId} berhasil!',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/home');
          } else if (state is BookingCancelledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Booking ${state.bookingId} dibatalkan karena pembayaran tidak selesai.',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          } else if (state is BookingWaitingForPayment) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Booking ${state.bookingId} menunggu pembayaran. Silakan selesaikan transaksi Anda.',
                ),
                backgroundColor: AppColors.secondary,
              ),
            );
          } else if (state is BookingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          body: BlocBuilder<VenueBloc, VenueState>(
            builder: (context, venueState) {
              if (venueState is VenueDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (venueState is VenueError) {
                return Center(child: Text(venueState.message));
              } else if (venueState is VenueDetailLoaded) {
                return _buildContent(
                  context,
                  venueState.venue,
                  venueState.courts,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          bottomNavigationBar: _buildBottomBar(context),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingAvailabilityLoaded &&
            state.selectedStartTime != null) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login untuk melakukan booking'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    context.push('/login');
                    return;
                  }

                  final venueState = context.read<VenueBloc>().state;
                  if (venueState is VenueDetailLoaded) {
                    final court = venueState.courts.firstWhere(
                      (c) => c.id == state.selectedCourtId,
                    );
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) {
                        return BlocProvider.value(
                          value: context.read<BookingBloc>(),
                          child: BookingBottomSheet(
                            venue: venueState.venue,
                            court: court,
                            date: state.selectedDate,
                            startTime: state.selectedStartTime!,
                          ),
                        );
                      },
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lanjut ke Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, Venue venue, List<Court> courts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              venue.name,
              style: const TextStyle(
                color: Colors.white,
                shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                venue.photos.isNotEmpty
                    ? PageView.builder(
                        itemCount: venue.photos.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            venue.photos[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey),
                          );
                        },
                      )
                    : Container(color: Colors.grey),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
                if (venue.photos.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        venue.photos.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue.city,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(venue.address),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            venue.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Fasilitas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: venue.facilities.map((facility) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // In a real app, map facility string to icon
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            facility,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 32),
                _buildDatePicker(context),
                const SizedBox(height: 24),
                Text(
                  'Pilih Lapangan & Jadwal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                courts.isEmpty
                    ? const Center(child: Text('Tidak ada lapangan tersedia.'))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: courts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildCourtItem(context, courts[index]);
                        },
                      ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.secondary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal Booking',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  DateFormat(
                    'EEEE, d MMMM yyyy',
                    'id_ID',
                  ).format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtItem(BuildContext context, Court court) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        bool isSelected = false;
        if (state is BookingAvailabilityLoaded) {
          isSelected = state.selectedCourtId == court.id;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  if (!isSelected) {
                    context.read<BookingBloc>().add(
                      BookingAvailabilityChecked(
                        courtId: court.id,
                        date: _selectedDate,
                      ),
                    );
                  }
                },
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(
                    Icons.sports_tennis,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text(
                  court.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(court.sportType),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatter.format(court.hourlyPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text('/ jam', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              if (isSelected) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Jam Main',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      const BookingTimeSlotGrid(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePaymentNavigation(
    BuildContext context,
    BookingPaymentPageReady state,
  ) async {
    final result = await context.push<String>(
      '/payment',
      extra: state.paymentUrl,
    );

    context.read<BookingBloc>().add(
      BookingPaymentCompleted(
        bookingId: state.bookingId,
        status: result ?? 'cancelled',
      ),
    );
  }
}