import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

class OrderFilterBar extends StatelessWidget {
  const OrderFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderManagementBloc, OrderManagementState>(
      builder: (context, state) {
        if (state is! OrderManagementLoaded) return const SizedBox.shrink();

        // 1. Extract Unique Data for Dropdowns (Cascading from availableVenues)
        final venues = state.availableVenues;
        final sports = <String>{};
        final courts = <String, String>{}; // id -> name

        // Determine available sports and courts based on selected venue
        Venue? selectedVenue;
        try {
          selectedVenue = venues.firstWhere((v) => v.id == state.filterVenueId);
        } catch (_) {
          selectedVenue = null;
        }

        if (selectedVenue != null) {
          // If venue selected, show its specific sports and courts
          for (var court in selectedVenue.courts) {
            sports.add(court.sportType);
            if (state.filterSportType == null ||
                court.sportType == state.filterSportType) {
              courts[court.id] = court.name;
            }
          }
        } else {
          // If no venue selected, show all available sports and courts from inventory
          for (var venue in venues) {
            for (var court in venue.courts) {
              sports.add(court.sportType);
              if (state.filterSportType == null ||
                  court.sportType == state.filterSportType) {
                courts[court.id] = court.name;
              }
            }
          }
        }

        final sortedSports = sports.toList()..sort();
        final sortedCourts = courts.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        final bool hasActiveFilters =
            state.filterVenueId != null ||
            state.filterCourtId != null ||
            state.filterSportType != null ||
            state.filterStatus != null ||
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
                },
                onClear: state.filterDateRange != null
                    ? () {
                        context.read<OrderManagementBloc>().add(
                          const OrderManagementFilterChanged(clearDate: true),
                        );
                      }
                    : null,
              ),

              const SizedBox(width: 8),

              // Status Filter
              _DropdownFilter(
                hint: 'Status',
                value: state.filterStatus,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Semua Status')),
                  DropdownMenuItem(
                    value: 'waiting_payment',
                    child: Text('Menunggu Pembayaran'),
                  ),
                  DropdownMenuItem(value: 'paid', child: Text('Lunas')),
                  DropdownMenuItem(value: 'completed', child: Text('Selesai')),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Dibatalkan'),
                  ),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('Maintenance'),
                  ),
                ],
                onChanged: (val) {
                  context.read<OrderManagementBloc>().add(
                    OrderManagementFilterChanged(status: val ?? ''),
                  );
                },
              ),

              const SizedBox(width: 8),

              // Venue Filter
              _DropdownFilter(
                hint: 'Venue',
                value: state.filterVenueId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Venue'),
                  ),
                  ...venues.map(
                    (v) => DropdownMenuItem(value: v.id, child: Text(v.name)),
                  ),
                ],
                onChanged: (val) {
                  context.read<OrderManagementBloc>().add(
                    OrderManagementFilterChanged(
                      venueId: val ?? '',
                      courtId: '', // Reset court
                      sportType: '', // Reset sport
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              // Sport Filter
              _DropdownFilter(
                hint: 'Olahraga',
                value: state.filterSportType,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Olahraga'),
                  ),
                  ...sortedSports.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s)),
                  ),
                ],
                onChanged: (val) {
                  context.read<OrderManagementBloc>().add(
                    OrderManagementFilterChanged(
                      sportType: val ?? '',
                      courtId: '',
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              // Court Filter
              _DropdownFilter(
                hint: 'Lapangan',
                value: state.filterCourtId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Lapangan'),
                  ),
                  ...sortedCourts.map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ),
                ],
                onChanged: (val) {
                  context.read<OrderManagementBloc>().add(
                    OrderManagementFilterChanged(courtId: val ?? ''),
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
            if (isActive && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.cancel,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ] else if (isActive) ...[
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
