import 'package:firebase_auth/firebase_auth.dart';
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

class VenueDetailPage extends StatefulWidget {
  final String venueId;

  const VenueDetailPage({super.key, required this.venueId});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  DateTime _selectedDate = DateTime.now();
  int _currentImageIndex = 0; // Track carousel index

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
        // Layer 1: Image Carousel (Fixed height)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.4, // 40% height
          child: Stack(
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
              // Gradient Overlay for visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              // Dots Indicator
              if (venue.photos.length > 1)
                Positioned(
                  bottom: 48, // Above the overlapping card
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
                              : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Layer 2: Custom App Bar (Floating)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white, // White icons
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to Favorites')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Layer 3: Content Body (Overlapping)
        Positioned.fill(
          top: MediaQuery.of(context).size.height * 0.35, // Overlap by 5%
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
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
                      const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 18, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        venue.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                              ),
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
                        avatar: const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
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
                          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) => _buildCourtItem(context, courts[i]),
                        ),
                  const SizedBox(height: 100), // Space for sticky bottom bar
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == _selectedDate.day && 
                               date.month == _selectedDate.month;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
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
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
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
            color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
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
                  child: const Icon(Icons.sports_tennis, color: AppColors.primary),
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
                      Text('Available Slots', style: Theme.of(context).textTheme.labelMedium),
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
        if (state is BookingAvailabilityLoaded && state.selectedStartTime != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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

  void _onBookingPressed(BuildContext context, BookingAvailabilityLoaded state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required to book')),
      );
      context.push('/login');
      return;
    }

    final venueState = context.read<VenueBloc>().state;
    if (venueState is VenueDetailLoaded) {
      final court = venueState.courts.firstWhere((c) => c.id == state.selectedCourtId);
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
