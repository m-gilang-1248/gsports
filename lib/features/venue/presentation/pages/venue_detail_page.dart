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
import 'package:gsports/features/favorites/presentation/bloc/favorites_bloc.dart';
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
  String? _selectedSportType;
  int _currentImageIndex = 0;

  late ScrollController _scrollController;
  late PageController _pageController;
  late ScrollController _dateScrollController;

  bool _isCollapsed = false;

  // Static date range: Today to +365 days
  late final List<DateTime> _displayDates;

  @override
  void initState() {
    super.initState();
    context.read<VenueBloc>().add(VenueFetchDetailRequested(widget.venueId));

    // Initialize display dates once
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _displayDates = List.generate(
      365,
      (index) => today.add(Duration(days: index)),
    );

    _scrollController = ScrollController();
    _pageController = PageController();
    _dateScrollController = ScrollController();

    _scrollController.addListener(() {
      final collapsed =
          _scrollController.hasClients && _scrollController.offset > 200;
      if (collapsed != _isCollapsed) {
        setState(() {
          _isCollapsed = collapsed;
        });
      }
    });

    // Initial scroll to today (index 0) is default,
    // but if we ever allow deep linking to a date, we'd use _scrollToCenteredDate here.
  }

  void _scrollToCenteredDate(DateTime date) {
    if (!_dateScrollController.hasClients) return;

    final index = _displayDates.indexWhere((d) => DateUtils.isSameDay(d, date));
    if (index == -1) return;

    final screenWidth = MediaQuery.of(context).size.width;
    const itemWidth = 72.0; // 60 width + 12 margin
    final targetOffset =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _dateScrollController.animateTo(
      targetOffset.clamp(0.0, _dateScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<BookingBloc>()),
        BlocProvider(
          create: (context) {
            final bloc = getIt<FavoritesBloc>();
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              bloc.add(CheckIsFavoriteRequested(user.uid, widget.venueId));
            }
            return bloc;
          },
        ),
      ],
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
          backgroundColor: AppColors.background,
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

    final sportTypes = courts.map((c) => c.sportType).toSet().toList();
    if (_selectedSportType == null && sportTypes.isNotEmpty) {
      _selectedSportType = sportTypes.first;
    }

    final filteredCourts = _selectedSportType == null
        ? courts
        : courts.where((c) => c.sportType == _selectedSportType).toList();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 1. App Bar
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          actions: [
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFav = false;
                if (state is FavoriteStatusLoaded) {
                  isFav = state.isFavorite;
                }
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : AppColors.textPrimary,
                  ),
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login required')),
                      );
                      return;
                    }
                    context.read<FavoritesBloc>().add(
                      ToggleFavoriteRequested(user.uid, venue),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.textPrimary),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),

        // 2. Carousel
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Stack(
                  children: [
                    venue.photos.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            itemCount: venue.photos.length,
                            onPageChanged: (index) {
                              setState(() => _currentImageIndex = index);
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
                    if (venue.photos.length > 1)
                      Positioned(
                        bottom: 16,
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
            ],
          ),
        ),

        // 3. Venue Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    const Icon(Icons.star, size: 18, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      venue.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSportBadges(venue, courts),
                const SizedBox(height: 24),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                const Divider(),
              ],
            ),
          ),
        ),

        // 4. Combined Sticky Header
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFiltersDelegate(
            height: sportTypes.length > 1 ? 230 : 170,
            child: Material(
              color: AppColors.background,
              child: Column(
                children: [
                  _buildDatePicker(context),
                  if (sportTypes.length > 1)
                    _buildSportTabs(context, sportTypes),
                ],
              ),
            ),
          ),
        ),

        // Courts List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          sliver: filteredCourts.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No courts available')),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCourtItem(context, filteredCourts[index]),
                    ),
                    childCount: filteredCourts.length,
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 0, 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Select Date',

                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.calendar_month,

                    color: AppColors.primary,
                  ),

                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,

                      initialDate: _selectedDate,

                      firstDate: _displayDates.first,

                      lastDate: _displayDates.last,
                    );

                    if (date != null && context.mounted) {
                      setState(() => _selectedDate = date);

                      _scrollToCenteredDate(date);

                      context.read<BookingBloc>().add(BookingSelectionReset());
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 85,

            child: ListView.builder(
              controller: _dateScrollController,

              scrollDirection: Axis.horizontal,

              physics: const BouncingScrollPhysics(),

              itemCount: _displayDates.length,

              itemBuilder: (context, index) {
                final date = _displayDates[index];

                final isSelected = DateUtils.isSameDay(date, _selectedDate);

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);

                    _scrollToCenteredDate(date);

                    context.read<BookingBloc>().add(BookingSelectionReset());
                  },

                  child: Container(
                    width: 60,

                    margin: const EdgeInsets.only(right: 12),

                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,

                        width: isSelected ? 2 : 1,
                      ),

                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),

                                blurRadius: 4,

                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          DateFormat('MMM').format(date),

                          style: TextStyle(
                            fontSize: 10,

                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,

                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),

                        Text(
                          date.day.toString(),

                          style: TextStyle(
                            fontSize: 18,

                            fontWeight: FontWeight.bold,

                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),

                        Text(
                          DateFormat('E').format(date),

                          style: TextStyle(
                            fontSize: 10,

                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,

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
      ),
    );
  }

  Widget _buildSportTabs(BuildContext context, List<String> sportTypes) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: sportTypes.length,
        itemBuilder: (context, index) {
          final sport = sportTypes[index];
          final isSelected = sport == _selectedSportType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(sport),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedSportType = sport);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSportBadges(Venue venue, List<Court> courts) {
    final sportIds = courts.map((c) => c.sportType).toSet().toList();
    final detectedSports = AppConstants.sports
        .where((s) => sportIds.contains(s.id))
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: detectedSports.map((sport) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                  fontSize: 10,
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
                  if (!isSelected) {
                    final venueState = context.read<VenueBloc>().state;
                    if (venueState is VenueDetailLoaded) {
                      context.read<BookingBloc>().add(
                        BookingAvailabilityChecked(
                          courtId: court.id,
                          date: _selectedDate,
                          operatingHours: venueState.venue.operatingHours,
                        ),
                      );
                    }
                  }
                },
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.neutral,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: court.photos.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            court.photos.first,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
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
                      if (court.photos.isNotEmpty) ...[
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: court.photos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(court.photos[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (court.description.isNotEmpty) ...[
                        Text(
                          court.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
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
    final status = result ?? 'pending';
    context.read<BookingBloc>().add(
      BookingPaymentCompleted(bookingId: state.bookingId, status: status),
    );
  }
}

class _StickyFiltersDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyFiltersDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyFiltersDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
