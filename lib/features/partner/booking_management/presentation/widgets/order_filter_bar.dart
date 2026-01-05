import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';

class OrderFilterBar extends StatelessWidget {
  const OrderFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderManagementBloc, OrderManagementState>(
      builder: (context, state) {
        if (state is! OrderManagementLoaded) return const SizedBox.shrink();

        final allBookings = state.allBookings;

        // 1. Extract Unique Data for Dropdowns
        final venues = <String, String>{}; // id -> name
        final sports = <String>{};
        final courts =
            <String, String>{}; // id -> name, filtered by venue if selected

        for (var b in allBookings) {
          if (b.venueId.isNotEmpty && b.venueName != null) {
            venues[b.venueId] = b.venueName!;
          }
          if (b.sportType.isNotEmpty) {
            sports.add(b.sportType);
          }

          // Only collect courts that match selected venue (if any)
          if (state.filterVenueId == null || b.venueId == state.filterVenueId) {
            if (b.courtId.isNotEmpty && b.courtName != null) {
              courts[b.courtId] = b.courtName!;
            }
          }
        }

        final sortedVenues = venues.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        final sortedSports = sports.toList()..sort();
        final sortedCourts = courts.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        final bool hasActiveFilters =
            state.filterVenueId != null ||
            state.filterCourtId != null ||
            state.filterSportType != null ||
            state.filterDateRange != null;

        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // Date Range Filter
              _FilterChip(
                label: state.filterDateRange == null
                    ? 'Pilih Tanggal'
                    : '${DateFormat('d MMM').format(state.filterDateRange!.start)} - ${DateFormat('d MMM').format(state.filterDateRange!.end)}',
                isActive: state.filterDateRange != null,
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: state.filterDateRange,
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: AppColors.primary,
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black87,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (range != null && context.mounted) {
                                        context.read<OrderManagementBloc>().add(
                                              OrderManagementFilterChanged(dateRange: range),
                                            );
                                      }
                                    },                onClear: state.filterDateRange != null
                    ? () =>
                          context.read<OrderManagementBloc>().add(
                            const OrderManagementFilterChanged(clearAll: false),
                          ) // This is tricky, we need a way to clear specific
                    : null,
              ),

              const SizedBox(width: 8),

              // Venue Filter
              _DropdownFilter(
                hint: 'Venue',
                value: state.filterVenueId,
                items: sortedVenues
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (val) {
                  context.read<OrderManagementBloc>().add(
                    OrderManagementFilterChanged(
                      venueId: val,
                      courtId: null,
                    ), // Reset court if venue changes
                  );
                },
              ),

              const SizedBox(width: 8),

              // Court Filter
              _DropdownFilter(
                hint: 'Lapangan',
                value: state.filterCourtId,
                items: sortedCourts
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (val) {
                  context.read<OrderManagementBloc>().add(
                    OrderManagementFilterChanged(courtId: val),
                  );
                },
              ),

              const SizedBox(width: 8),

              // Sport Filter
              _DropdownFilter(
                hint: 'Olahraga',
                value: state.filterSportType,
                items: sortedSports
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  context.read<OrderManagementBloc>().add(
                    OrderManagementFilterChanged(sportType: val),
                  );
                },
              ),

              if (hasActiveFilters) ...[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    context.read<OrderManagementBloc>().add(
                      const OrderManagementFilterChanged(clearAll: true),
                    );
                  },
                  icon: const Icon(
                    Icons.clear_all,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.grey.shade700,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value != null
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value != null ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: TextStyle(
            color: value != null ? AppColors.primary : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
