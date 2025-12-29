import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../../features/venue/domain/entities/venue.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;

  const VenueCard({super.key, required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Detect sports based on name and facilities using the registry (Fallback)
    final detectedSports = AppConstants.sports.where((sport) {
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
    }).toList();

    // Use venue.sportCategories if available, otherwise fallback to detectedSports
    final List<String> categoriesToDisplay = venue.sportCategories.isNotEmpty
        ? venue.sportCategories
        : detectedSports.map((s) => s.id).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10, // v2.2 Spec
                    child: venue.photos.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: venue.photos.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.neutral,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.neutral,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.neutral,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                  // Overlapping Sport Icons (Overlay)
                  if (categoriesToDisplay.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildSportBadges(categoriesToDisplay),
                    ),
                  // Rating Pill (Keeping this as it's useful)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            venue.rating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left Side: Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  venue.city,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Side: Price (Vertical)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Start from',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          currencyFormat.format(venue.minPrice),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportBadges(List<String> categories) {
    const double size = 32.0;
    const double overlap = 8.0;
    final displayCategories = categories.take(3).toList();
    final hasMore = categories.length > 3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(displayCategories.length, (index) {
        final isLastAndMore = hasMore && index == 2;
        final category = displayCategories[index];

        return Container(
          width: size,
          height: size,
          margin: EdgeInsets.only(left: index == 0 ? 0 : -overlap),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isLastAndMore
                ? Text(
                    '+${categories.length - 2}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Icon(
                    AppConstants.getSportIcon(category),
                    size: 18,
                    color: AppColors.primary,
                  ),
          ),
        );
      }),
    );
  }
}
