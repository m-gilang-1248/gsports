import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/presentation/widgets/venue_card.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/venue/presentation/bloc/venue_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
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
              _buildVenueList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi Anda',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    'Jakarta', // Hardcoded for MVP
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Implement Notifications
                    },
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textPrimary),
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
                  )
                ],
              ),
            ],
          );
        } else {
          // Guest State
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    'Cari Lapangan?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Masuk',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textTertiary),
            ),
            const Spacer(),
            const Icon(Icons.tune, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRail(BuildContext context) {
    final categories = [
      {'name': 'Badminton', 'icon': Icons.sports_tennis},
      {'name': 'Futsal', 'icon': Icons.sports_soccer},
      {'name': 'Tennis', 'icon': Icons.sports_tennis_outlined},
      {'name': 'Basketball', 'icon': Icons.sports_basketball},
      {'name': 'Golf', 'icon': Icons.sports_golf},
      {'name': 'Volley', 'icon': Icons.sports_volleyball},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                context.push('/search?category=${category['name']}');
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
                    child: Icon(
                      category['icon'] as IconData,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] as String,
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

  Widget _buildVenueList() {
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
          if (state.venues.isEmpty) {
            return const SliverFillRemaining(
              child: Center(child: Text('Tidak ada lapangan ditemukan.')),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final venue = state.venues[index];
                  return VenueCard(
                    venue: venue,
                    onTap: () {
                      context.push('/venue/${venue.id}');
                    },
                  );
                },
                childCount: state.venues.length,
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
