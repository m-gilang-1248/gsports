import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/core/presentation/widgets/venue_card.dart';
import 'package:gsports/core/services/location_service.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/venue/presentation/bloc/venue_bloc.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<VenueBloc>();
    if (bloc.state is! VenueListLoaded) {
      bloc.add(VenueFetchListRequested());
    }
  }

  Future<void> _detectLocation() async {
    try {
      final locationService = GetIt.I<LocationService>();
      final position = await locationService.getCurrentPosition();
      final cityName = await locationService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        context.read<VenueBloc>().add(
          VenueLocationDetected(
            lat: position.latitude,
            lng: position.longitude,
            cityName: cityName,
          ),
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lokasi terdeteksi: $cityName')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendeteksi lokasi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<VenueBloc>().add(VenueFetchListRequested());
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildSearchBar(context),
                      const SizedBox(height: 24),
                      _buildCategoryRail(context),
                      const SizedBox(height: 24),
                      Text(
                        'Rekomendasi Lapangan',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildVenueList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, venueState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            String? selectedCity;
            List<String> cities = [];

            if (venueState is VenueListLoaded) {
              selectedCity = venueState.selectedCity;
              cities = venueState.availableCities;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState is AuthAuthenticated
                            ? 'Lokasi Anda'
                            : 'Selamat Datang, Cari Lapangan?',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          if (venueState is VenueListLoaded)
                            DropdownButton<String>(
                              value:
                                  (selectedCity != null &&
                                      cities.contains(selectedCity))
                                  ? selectedCity
                                  : null,
                              hint: Text(
                                'Pilih Kota',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 18,
                                    ),
                              ),
                              underline: const SizedBox.shrink(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.primary,
                              ),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 18,
                                  ),
                              items: cities.map((city) {
                                return DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<VenueBloc>().add(
                                    VenueSearchRequested(
                                      query: '',
                                      city: value,
                                    ),
                                  );
                                }
                              },
                            )
                          else
                            const Text('Memuat...'),
                          const Spacer(),
                          IconButton(
                            onPressed: _detectLocation,
                            icon: const Icon(
                              Icons.my_location,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Gunakan Lokasi Saat Ini',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Implement Notifications Page
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
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
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              'Cari lapangan...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            ),
            const Spacer(),
            const Icon(Icons.tune, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRail(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.sports.length,
        itemBuilder: (context, index) {
          final sport = AppConstants.sports[index];
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                context.push('/search?category=${sport.id}');
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.neutral,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(sport.icon, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sport.displayName,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueList(BuildContext context) {
    return BlocBuilder<VenueBloc, VenueState>(
      buildWhen: (previous, current) =>
          current is VenueListLoaded ||
          current is VenueListLoading ||
          current is VenueError,
      builder: (context, state) {
        if (state is VenueListLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is VenueError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VenueBloc>().add(VenueFetchListRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is VenueListLoaded) {
          if (state.filteredVenues.isEmpty) {
            return const SliverFillRemaining(
              child: Center(child: Text('Tidak ada lapangan ditemukan.')),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final venue = state.filteredVenues[index];
                return VenueCard(
                  venue: venue,
                  userLat: state.userLat,
                  userLng: state.userLng,
                  onTap: () {
                    context.push('/venue/${venue.id}');
                  },
                );
              }, childCount: state.filteredVenues.length),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
