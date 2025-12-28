import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/venue_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:intl/intl.dart';

class VenuesView extends StatelessWidget {
  const VenuesView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<VenueManagementBloc>().add(FetchMyVenues());
      },
      child: BlocConsumer<VenueManagementBloc, VenueManagementState>(
        listener: (context, state) {
          if (state is VenueActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<VenueManagementBloc>().add(FetchMyVenues());
          } else if (state is VenueManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VenueManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VenueManagementSuccess) {
            if (state.venues.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stadium_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada venue ditambahkan.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.venues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final venue = state.venues[index];
                return _buildVenueCard(context, venue);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context, Venue venue) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () =>
            context.push('/venue-courts/${venue.id}', extra: venue.name),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: venue.photos.isNotEmpty
                    ? Image.network(venue.photos[0], fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (venue.isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${venue.city}, ${venue.address}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currencyFormat.format(venue.minPrice)} / jam',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final result = await context.push(
                                '/edit-venue',
                                extra: venue,
                              );
                              if (result == true && context.mounted) {
                                context.read<VenueManagementBloc>().add(
                                  FetchMyVenues(),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                            ),
                            tooltip: 'Edit Details',
                          ),
                          IconButton(
                            onPressed: () =>
                                _showDeleteConfirmation(context, venue.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String venueId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Venue'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus venue ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<VenueManagementBloc>().add(
                DeleteVenueRequested(venueId),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}