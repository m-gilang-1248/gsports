import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/availability/availability_bloc.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue_holiday.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityManagementPage extends StatelessWidget {
  const AvailabilityManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<AvailabilityBloc>()..add(AvailabilityInit()),
      child: const AvailabilityManagementView(),
    );
  }
}

class AvailabilityManagementView extends StatefulWidget {
  const AvailabilityManagementView({super.key});

  @override
  State<AvailabilityManagementView> createState() =>
      _AvailabilityManagementViewState();
}

class _AvailabilityManagementViewState
    extends State<AvailabilityManagementView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AvailabilityBloc, AvailabilityState>(
      listener: (context, state) {
        if (state is AvailabilityActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is AvailabilityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Atur Libur & Ketersediaan')),
        body: BlocBuilder<AvailabilityBloc, AvailabilityState>(
          builder: (context, state) {
            if (state is AvailabilityLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AvailabilityError) {
              return Center(child: Text(state.message));
            }
            if (state is AvailabilityLoaded) {
              if (state.venues.isEmpty) {
                return const Center(child: Text("Belum ada venue."));
              }
              return Column(
                children: [
                  _buildFilters(context, state),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildCalendar(context, state),
                          _buildLegend(),
                          const Divider(),
                          _buildBlockedList(context, state),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<AvailabilityBloc, AvailabilityState>(
          builder: (context, state) {
            if (state is AvailabilityLoaded && state.selectedVenue != null) {
              return FloatingActionButton.extended(
                onPressed: () {
                  if (_selectedDay == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih tanggal terlebih dahulu'),
                      ),
                    );
                    return;
                  }
                  context.read<AvailabilityBloc>().add(
                    AvailabilityAddBlock(_selectedDay!),
                  );
                },
                label: Text(
                  state.selectedCourt != null
                      ? 'Blokir Court Ini'
                      : 'Blokir Venue (Libur)',
                ),
                icon: const Icon(Icons.block),
                backgroundColor: AppColors.primary,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, AvailabilityLoaded state) {
    final sportTypes = state.courts.map((c) => c.sportType).toSet().toList();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Venue Dropdown
          DropdownButtonFormField<Venue>(
            initialValue: state.selectedVenue,
            decoration: const InputDecoration(
              labelText: 'Pilih Venue',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: state.venues.map((venue) {
              return DropdownMenuItem(
                value: venue,
                child: Text(venue.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (Venue? newValue) {
              if (newValue != null) {
                context.read<AvailabilityBloc>().add(
                  AvailabilityVenueSelected(newValue),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          // Sport Type Dropdown
          DropdownButtonFormField<String?>(
            initialValue: state.selectedSportType,
            decoration: const InputDecoration(
              labelText: 'Filter Jenis Olahraga',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Semua Jenis Olahraga'),
              ),
              ...sportTypes.map((type) {
                return DropdownMenuItem<String?>(
                  value: type,
                  child: Text(type),
                );
              }),
            ],
            onChanged: (String? newValue) {
              context.read<AvailabilityBloc>().add(
                AvailabilitySportTypeSelected(newValue),
              );
            },
          ),
          const SizedBox(height: 16),
          // Court Dropdown
          DropdownButtonFormField<Court?>(
            initialValue: state.selectedCourt,
            decoration: const InputDecoration(
              labelText: 'Filter Court (Opsional)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem<Court?>(
                value: null,
                child: Text('Semua Court'),
              ),
              ...state.courts
                  .where(
                    (c) =>
                        state.selectedSportType == null ||
                        c.sportType == state.selectedSportType,
                  )
                  .map((court) {
                    return DropdownMenuItem<Court?>(
                      value: court,
                      child: Text('${court.name} (${court.sportType})'),
                    );
                  }),
            ],
            onChanged: (Court? newValue) {
              context.read<AvailabilityBloc>().add(
                AvailabilityCourtSelected(newValue),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, AvailabilityLoaded state) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        context.read<AvailabilityBloc>().add(
          AvailabilityMonthChanged(focusedDay),
        );
      },
      eventLoader: (day) {
        final events = <dynamic>[];

        // 1. Venue Holidays (Entire Venue Closed)
        if (state.selectedVenue != null) {
          for (final holiday in state.selectedVenue!.holidays) {
            if (day.isAfter(
                  holiday.startDate.subtract(const Duration(days: 1)),
                ) &&
                day.isBefore(holiday.endDate.add(const Duration(days: 1)))) {
              // Simple day check logic, better with isSameDay loop or range check
              // Actually table_calendar calls this for every day.
              // We need to check if 'day' is within holiday range.
              if (_isWithinRange(day, holiday.startDate, holiday.endDate)) {
                events.add('Holiday: ${holiday.name}');
              }
            }
          }
        }

        // 2. Maintenance (Blocked Courts)
        // Filter maintenance bookings by selectedCourt if any
        final relevantMaintenance = state.maintenanceBookings.where((booking) {
          if (state.selectedCourt != null) {
            return booking.courtId == state.selectedCourt!.id;
          }
          return true;
        });

        for (final booking in relevantMaintenance) {
          if (isSameDay(day, booking.date)) {
            events.add('Maintenance: ${booking.courtName}');
          }
        }

        return events;
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;

          bool hasHoliday = events.any(
            (e) => e.toString().startsWith('Holiday'),
          );
          bool hasMaintenance = events.any(
            (e) => e.toString().startsWith('Maintenance'),
          );

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasHoliday)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.error, // Red for Holiday
                    shape: BoxShape.circle,
                  ),
                ),
              if (hasMaintenance)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.orange, // Orange for Maintenance
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlockedList(BuildContext context, AvailabilityLoaded state) {
    if (_selectedDay == null) return const SizedBox.shrink();

    // 1. Get Venue Holidays for selected day
    final holidays =
        state.selectedVenue?.holidays.where((h) {
          return _isWithinRange(_selectedDay!, h.startDate, h.endDate);
        }).toList() ??
        [];

    // 2. Get Maintenance for selected day
    final maintenance = state.maintenanceBookings.where((m) {
      return isSameDay(m.date, _selectedDay!);
    }).toList();

    if (holidays.isEmpty && maintenance.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Tidak ada pemblokiran pada tanggal ini',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (holidays.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Libur Toko (Venue)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...holidays.map(
              (h) => ListTile(
                leading: const Icon(Icons.store, color: AppColors.error),
                title: Text(h.name),
                subtitle: const Text('Seluruh Venue Tutup'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () => _showDeleteConfirmation(context, holiday: h),
                ),
              ),
            ),
            const Divider(),
          ],
          if (maintenance.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Maintenance Lapangan (Blocked)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...maintenance.map(
              (m) => ListTile(
                leading: const Icon(Icons.handyman, color: Colors.orange),
                title: Text('${m.courtName ?? 'Court'} (${m.sportType})'),
                subtitle: Text('Status: ${m.status.toUpperCase()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () =>
                      _showDeleteConfirmation(context, bookingId: m.id),
                ),
              ),
            ),
          ],
          const SizedBox(height: 80), // Extra space for FAB
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context, {
    String? bookingId,
    VenueHoliday? holiday,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pemblokiran'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pemblokiran ini? '
          'Slot akan kembali tersedia untuk dipesan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AvailabilityBloc>().add(
                AvailabilityDeleteBlock(bookingId: bookingId, holiday: holiday),
              );
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

  bool _isWithinRange(DateTime day, DateTime start, DateTime end) {
    // Normalize to YMD
    final check = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return (check.isAtSameMomentAs(s) || check.isAfter(s)) &&
        (check.isAtSameMomentAs(e) || check.isBefore(e));
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Libur Toko (Tutup)'),
            ],
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Maintenance'),
            ],
          ),
        ],
      ),
    );
  }
}
