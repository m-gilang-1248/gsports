import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/court_management_bloc.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/venue_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:intl/intl.dart';

class VenueCourtsPage extends StatelessWidget {
  final String venueId;
  final String venueName;

  const VenueCourtsPage({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetIt.I<CourtManagementBloc>()..add(FetchCourts(venueId)),
        ),
        // Ensure VenueManagementBloc is available to find the venue object
        BlocProvider(
          create: (context) => GetIt.I<VenueManagementBloc>()..add(FetchMyVenues()),
        ),
      ],
      child: _VenueCourtsView(venueId: venueId, venueName: venueName),
    );
  }
}

class _VenueCourtsView extends StatelessWidget {
  final String venueId;
  final String venueName;

  const _VenueCourtsView({required this.venueId, required this.venueName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('$venueName Courts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/venue-courts/$venueId/add');
          if (context.mounted) {
            context.read<CourtManagementBloc>().add(FetchCourts(venueId));
          }
        },
        label: const Text('Add Court', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<CourtManagementBloc, CourtManagementState>(
        builder: (context, state) {
          if (state is CourtManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourtManagementError) {
            return Center(child: Text(state.message));
          } else if (state is CourtManagementLoaded) {
            if (state.courts.isEmpty) {
              return const Center(child: Text('No courts added yet.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.courts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) =>
                  _buildCourtCard(context, state.courts[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCourtCard(BuildContext context, Court court) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            AppConstants.getSportIcon(court.sportType),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          court.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${court.sportType} • ${currencyFormat.format(court.hourlyPrice)}/hr',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.build_outlined, color: Colors.orange),
              onPressed: () {
                // We need the venue object. Since it's not in the state of CourtManagementBloc,
                // and we don't want to refetch, we can try to find it in the VenueManagementBloc 
                // if it's available in the parent or just use venueId and rely on the page to handle it.
                // Best way: pass it via router or extras.
                final venueState = context.read<VenueManagementBloc>().state;
                if (venueState is VenueManagementSuccess) {
                  final venue = venueState.venues.firstWhere((v) => v.id == venueId);
                  context.push('/court-maintenance', extra: {
                    'venue': venue,
                    'court': court,
                  });
                }
              },
              tooltip: 'Maintenance',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                await context.push('/venue-courts/$venueId/edit', extra: court);
                if (context.mounted) {
                  context.read<CourtManagementBloc>().add(FetchCourts(venueId));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, court.id),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String courtId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Court'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CourtManagementBloc>().add(
                DeleteCourtRequested(venueId, courtId),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
