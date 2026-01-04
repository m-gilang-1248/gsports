import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:intl/intl.dart';

class CourtMaintenancePage extends StatefulWidget {
  final Venue venue;
  final Court court;

  const CourtMaintenancePage({
    super.key,
    required this.venue,
    required this.court,
  });

  @override
  State<CourtMaintenancePage> createState() => _CourtMaintenancePageState();
}

class _CourtMaintenancePageState extends State<CourtMaintenancePage> {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _selectedSlots = [];

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  void _checkAvailability() {
    // We reuse BookingBloc to see current availability
    final Map<String, dynamic> operatingHoursWithHolidays =
        Map<String, dynamic>.from(widget.venue.operatingHours ?? {});
    operatingHoursWithHolidays['holidays'] = widget.venue.holidays;

    context.read<BookingBloc>().add(
      BookingAvailabilityChecked(
        courtId: widget.court.id,
        date: _selectedDate,
        operatingHours: operatingHoursWithHolidays,
      ),
    );
  }

  void _submitMaintenance() {
    if (_selectedSlots.isEmpty) return;

    final sortedSlots = List<DateTime>.from(_selectedSlots)..sort();
    final startTime = sortedSlots.first;
    final endTime = sortedSlots.last.add(const Duration(hours: 1));
    final duration = sortedSlots.length;

    final booking = Booking(
      id: 'MAINT-${DateTime.now().millisecondsSinceEpoch}',
      userId: widget.venue.ownerId, // Maintenance belongs to owner
      venueId: widget.venue.id,
      ownerId: widget.venue.ownerId,
      courtId: widget.court.id,
      venueName: widget.venue.name,
      courtName: widget.court.name,
      venueLocation: widget.venue.address,
      sportType: widget.court.sportType,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      startTime: startTime,
      endTime: endTime,
      durationHours: duration,
      totalPrice: 0, // No cost for maintenance
      status: 'maintenance',
      paymentStatus: 'paid', // Mark as paid to avoid auto-cancellation
      participants: [
        PaymentParticipant(
          uid: widget.venue.ownerId,
          name: 'Maintenance',
          status: 'host',
          paymentStatusToHost: 'paid',
        ),
      ],
      participantIds: [widget.venue.ownerId],
      createdAt: DateTime.now(),
    );

    context.read<BookingBloc>().add(BookingCreated(booking));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingPaidSuccess || state is BookingSuccess) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance block created successfully'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        } else if (state is BookingFailure) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Court Maintenance'),
        ),
        body: Column(
          children: [
            _buildHeader(),
            _buildDatePicker(),
            const Divider(height: 1),
            Expanded(child: _buildSlotGrid()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppConstants.getSportIcon(widget.court.sportType),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.court.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                widget.court.sportType,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 90)),
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
              _selectedSlots.clear();
            });
            _checkAvailability();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Icon(Icons.calendar_today, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotGrid() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BookingAvailabilityLoaded) {
          final map = state.availabilityMap;
          final sortedHours = map.keys.toList()..sort();

          if (sortedHours.isEmpty) {
            return const Center(child: Text('Venue closed on this date.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: sortedHours.length,
            itemBuilder: (context, index) {
              final hour = sortedHours[index];
              final isAvailable = map[hour] ?? false;
              final isSelected = _selectedSlots.any((s) => s.hour == hour);
              
              final slotTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                hour,
              );

              return InkWell(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          if (isSelected) {
                            _selectedSlots.removeWhere((s) => s.hour == hour);
                          } else {
                            _selectedSlots.add(slotTime);
                          }
                        });
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isAvailable ? Colors.white : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isAvailable ? Colors.black : Colors.grey.shade400),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _selectedSlots.isEmpty ? null : _submitMaintenance,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _selectedSlots.isEmpty
                ? 'Select Slots to Block'
                : 'Block ${_selectedSlots.length} Slots for Maintenance',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
