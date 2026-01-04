import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/partner/venue_management/domain/repositories/venue_management_repository.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/venue_holiday.dart';
import 'package:intl/intl.dart';

class VenueHolidaysPage extends StatefulWidget {
  final Venue venue;

  const VenueHolidaysPage({super.key, required this.venue});

  @override
  State<VenueHolidaysPage> createState() => _VenueHolidaysPageState();
}

class _VenueHolidaysPageState extends State<VenueHolidaysPage> {
  late List<VenueHoliday> _holidays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _holidays = List.from(widget.venue.holidays);
    // Sort by date
    _holidays.sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Future<void> _addHoliday() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      final TextEditingController nameController = TextEditingController();
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Holiday Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'e.g., Eid Al-Fitr, New Year',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (confirm == true && nameController.text.isNotEmpty) {
        final newHoliday = VenueHoliday(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text,
          startDate: picked.start,
          endDate: picked.end,
        );

        // Conflict Check
        setState(() => _isSaving = true);
        final repo = GetIt.I<VenueManagementRepository>();
        final result = await repo.checkBookingConflicts(
          widget.venue.id,
          newHoliday.startDate,
          newHoliday.endDate,
        );

        result.fold(
          (failure) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (hasConflict) {
            setState(() => _isSaving = false);
            if (hasConflict) {
              if (mounted) {
                _showConflictDialog(newHoliday.startDate, newHoliday.endDate);
              }
            } else {
              setState(() {
                _holidays.add(newHoliday);
                _holidays.sort((a, b) => a.startDate.compareTo(b.startDate));
              });
              _saveHolidays();
            }
          },
        );
      }
    }
  }

  void _showConflictDialog(DateTime start, DateTime end) {
    final format = DateFormat('dd MMM yyyy');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Conflict'),
        content: Text(
          'There are active bookings between ${format.format(start)} and ${format.format(end)}. Please cancel them first before setting this period as a holiday.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _removeHoliday(int index) {
    setState(() {
      _holidays.removeAt(index);
    });
    _saveHolidays();
  }

  Future<void> _saveHolidays() async {
    setState(() => _isSaving = true);

    // Create updated venue object
    final updatedVenue = Venue(
      id: widget.venue.id,
      ownerId: widget.venue.ownerId,
      name: widget.venue.name,
      description: widget.venue.description,
      address: widget.venue.address,
      city: widget.venue.city,
      location: widget.venue.location,
      facilities: widget.venue.facilities,
      photos: widget.venue.photos,
      rating: widget.venue.rating,
      minPrice: widget.venue.minPrice,
      isVerified: widget.venue.isVerified,
      operatingHours: widget.venue.operatingHours,
      holidays: _holidays,
    );

    // Using GetIt to call repository directly or we could trigger Bloc event
    // To keep it simple and consistent with AddEditVenuePage, we use Bloc if available in context
    // But this page might not have it. Let's use repo directly or use Bloc.

    final repo = GetIt.I<VenueManagementRepository>();
    final result = await repo.updateVenue(updatedVenue);

    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Holidays updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: Text('${widget.venue.name} Holidays')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _addHoliday,
        label: const Text('Add Holiday'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
      body: _isSaving && _holidays.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _holidays.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _holidays.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final holiday = _holidays[index];
                final bool isPast = holiday.endDate.isBefore(DateTime.now());

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.grey.shade100
                            : AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: isPast ? Colors.grey : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      holiday.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${dateFormat.format(holiday.startDate)} - ${dateFormat.format(holiday.endDate)}',
                      style: TextStyle(
                        color: isPast ? Colors.grey : Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => _removeHoliday(index),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.beach_access_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No holidays scheduled',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mark dates when your venue will be closed.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
