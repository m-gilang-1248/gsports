import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/core/constants/facility_data.dart';
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
  int _currentImageIndex = 0;
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    context.read<VenueBloc>().add(VenueFetchDetailRequested(widget.venueId));
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final collapsed =
          _scrollController.hasClients &&
          _scrollController.offset >
              (MediaQuery.of(context).size.height * 0.4 - kToolbarHeight - 20);
      if (collapsed != _isCollapsed) {
        setState(() {
          _isCollapsed = collapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              const SnackBar(
                content: Text('Pembayaran berhasil!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/home');
          } else if (state is BookingWaitingForPayment) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Menunggu pembayaran. Silakan cek riwayat pesanan.',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
            context.go('/home');
          } else if (state is BookingCancelledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pembayaran dibatalkan'),
                backgroundColor: AppColors.error,
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
                return _buildLayout(
                  context,
                  venueState.venue,
                  venueState.courts,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          bottomNavigationBar: _buildStickyBottomBar(context),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, Venue venue, List<Court> courts) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.4,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              title: _isCollapsed
                  ? Text(
                      venue.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : null,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isCollapsed
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: _isCollapsed ? AppColors.textPrimary : Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCollapsed
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: _isCollapsed
                          ? AppColors.textPrimary
                          : Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to Favorites')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCollapsed
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.share,
                      color: _isCollapsed
                          ? AppColors.textPrimary
                          : Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    venue.photos.isNotEmpty
                        ? PageView.builder(
                            itemCount: venue.photos.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                venue.photos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey),
                              );
                            },
                          )
                        : Container(color: Colors.grey[300]),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    // Dots Indicator
                    if (venue.photos.length > 1)
                      Positioned(
                        bottom: 32,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            venue.photos.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentImageIndex == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Layer 2: Content Body (SliverToBoxAdapter with overlapped top)
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                transform: Matrix4.translationValues(
                  0,
                  -20,
                  0,
                ), // Slight overlap visual hack
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Title Header
                      Text(
                        venue.name,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              venue.address,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                      const SizedBox(height: 12),

                      // Sport Badges
                      _buildSportBadges(venue, courts),
                      const SizedBox(height: 24),

                      // 2. Price Block
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.neutral,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Start from',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              '${currencyFormat.format(venue.minPrice)} / jam',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        venue.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // 4. Facilities
                      Text(
                        'Facilities',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: venue.facilities.map((facility) {
                          return Chip(
                            label: Text(facility),
                            avatar: Icon(
                              kFacilityIcons[facility] ?? Icons.check_circle,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            backgroundColor: AppColors.surface,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 1,
                            shadowColor: Colors.black12,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Date Selection
                      _buildDatePicker(context),
                      const SizedBox(height: 24),

                      // Courts
                      Text(
                        'Choose Court',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      courts.isEmpty
                          ? const Center(child: Text('No courts available'))
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: courts.length,
                              separatorBuilder: (ctx, i) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, i) =>
                                  _buildCourtItem(context, courts[i]),
                            ),
                      const SizedBox(
                        height: 100,
                      ), // Space for sticky bottom bar
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSportBadges(Venue venue, List<Court> courts) {
    // Derive sports from actual courts available
    final sportIds = courts.map((c) => c.sportType.toLowerCase()).toSet();
    
    // Also include detection from name/facilities for robustness (fallback)
    final detectedFromVenue = AppConstants.sports.where((sport) {
      final queryId = sport.id.toLowerCase();
      final queryName = sport.displayName.toLowerCase();
      final keywords = sport.keywords.map((k) => k.toLowerCase()).toList();

      final inName =
          venue.name.toLowerCase().contains(queryId) ||
          venue.name.toLowerCase().contains(queryName) ||
          keywords.any((k) => venue.name.toLowerCase().contains(k));

      final inFacilities = venue.facilities.any((f) {
        final fLower = f.toLowerCase();
        return fLower.contains(queryId) ||
            fLower.contains(queryName) ||
            keywords.any((k) => fLower.contains(k));
      });

      return inName || inFacilities;
    }).map((s) => s.id.toLowerCase());

    final allSportIds = {...sportIds, ...detectedFromVenue};

    final detectedSports = AppConstants.sports
        .where((s) => allSportIds.contains(s.id.toLowerCase()))
        .toList();

    if (detectedSports.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: detectedSports.map((sport) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(sport.icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                sport.displayName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10, // Match VenueCard size
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month, color: AppColors.primary),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ), // Full calendar access
                );
                if (date != null && context.mounted) {
                  setState(() => _selectedDate = date);
                  // Refresh availability for the new date if a court is selected
                  final venueState = context.read<VenueBloc>().state;
                  final bookingState = context.read<BookingBloc>().state;
                  if (venueState is VenueDetailLoaded &&
                      bookingState is BookingAvailabilityLoaded) {
                    // Check availability again for the currently selected court but new date
                    context.read<BookingBloc>().add(
                      BookingAvailabilityChecked(
                        courtId: bookingState.selectedCourtId,
                        date: date,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected =
                  date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  // Trigger availability check update
                  final bookingState = context.read<BookingBloc>().state;
                  if (bookingState is BookingAvailabilityLoaded) {
                    context.read<BookingBloc>().add(
                      BookingAvailabilityChecked(
                        courtId: bookingState.selectedCourtId,
                        date: date,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourtItem(BuildContext context, Court court) {
    final currencyFormat = NumberFormat.currency(
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
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  // Only fetch if selecting a new court OR date changed (date logic handled in date picker)
                  if (!isSelected) {
                    context.read<BookingBloc>().add(
                      BookingAvailabilityChecked(
                        courtId: court.id,
                        date: _selectedDate,
                      ),
                    );
                  }
                },
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.neutral,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppConstants.getSportIcon(court.sportType),
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  court.name,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(court.sportType),
                trailing: Text(
                  currencyFormat.format(court.hourlyPrice),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
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
                        'Available Slots',
                        style: Theme.of(context).textTheme.labelMedium,
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

  Widget _buildStickyBottomBar(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingAvailabilityLoaded &&
            state.selectedSlots.isNotEmpty) {
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
                height: 50,
                child: FilledButton(
                  onPressed: () => _onBookingPressed(context, state),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _onBookingPressed(
    BuildContext context,
    BookingAvailabilityLoaded state,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login untuk melakukan booking')),
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
              selectedSlots: state.selectedSlots,
            ),
          );
        },
      );
    }
  }

  Future<void> _handlePaymentNavigation(
    BuildContext context,
    BookingPaymentPageReady state,
  ) async {
    final result = await context.push<String>(
      '/payment',
      extra: state.paymentUrl,
    );

    if (!context.mounted) return;

    // If result is null (back button), treat as pending so we can check status later
    final status = result ?? 'pending';
    context.read<BookingBloc>().add(
      BookingPaymentCompleted(bookingId: state.bookingId, status: status),
    );
  }
}
