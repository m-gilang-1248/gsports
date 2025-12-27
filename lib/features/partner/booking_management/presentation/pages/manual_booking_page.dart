import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/venue_management_bloc.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/court_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';

class ManualBookingPage extends StatelessWidget {
  const ManualBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetIt.I<VenueManagementBloc>()..add(FetchMyVenues()),
        ),
        BlocProvider(create: (context) => GetIt.I<CourtManagementBloc>()),
        BlocProvider(create: (context) => GetIt.I<BookingBloc>()),
      ],
      child: const _ManualBookingView(),
    );
  }
}

class _ManualBookingView extends StatefulWidget {
  const _ManualBookingView();

  @override
  State<_ManualBookingView> createState() => _ManualBookingViewState();
}

class _ManualBookingViewState extends State<_ManualBookingView> {
  Venue? _selectedVenue;
  Court? _selectedCourt;
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _selectedSlots = [];
  final TextEditingController _customerNameController = TextEditingController(
    text: 'Walk-in Guest',
  );

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Input Booking Manual'),
        backgroundColor: Colors.white,
      ),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingPaymentPageReady || state is BookingPaidSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking manual berhasil disimpan')),
            );
            Navigator.pop(context, true);
          } else if (state is BookingFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Venue Selection
              const Text(
                'Pilih Venue',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              BlocBuilder<VenueManagementBloc, VenueManagementState>(
                builder: (context, state) {
                  if (state is VenueManagementSuccess) {
                    return DropdownButtonFormField<Venue>(
                      initialValue: _selectedVenue,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      items: state.venues
                          .map(
                            (v) =>
                                DropdownMenuItem(value: v, child: Text(v.name)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedVenue = v;
                          _selectedCourt = null;
                          _selectedSlots.clear();
                        });
                        if (v != null) {
                          context.read<CourtManagementBloc>().add(
                            FetchCourts(v.id),
                          );
                        }
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),

              // 2. Court Selection
              if (_selectedVenue != null) ...[
                const Text(
                  'Pilih Lapangan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                BlocBuilder<CourtManagementBloc, CourtManagementState>(
                  builder: (context, state) {
                    if (state is CourtManagementLoaded) {
                      return DropdownButtonFormField<Court>(
                        initialValue: _selectedCourt,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        items: state.courts
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (c) {
                          setState(() {
                            _selectedCourt = c;
                            _selectedSlots.clear();
                          });
                          if (c != null) {
                            context.read<BookingBloc>().add(
                              BookingAvailabilityChecked(
                                courtId: c.id,
                                date: _selectedDate,
                              ),
                            );
                          }
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
              const SizedBox(height: 16),

              // 3. Date Selection
              if (_selectedCourt != null) ...[
                const Text(
                  'Pilih Tanggal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null && mounted) {
                      setState(() {
                        _selectedDate = date;
                        _selectedSlots.clear();
                      });
                      context.read<BookingBloc>().add(
                        BookingAvailabilityChecked(
                          courtId: _selectedCourt!.id,
                          date: date,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('d MMMM yyyy').format(_selectedDate)),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Time Selection
                const Text(
                  'Pilih Jam',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, state) {
                    if (state is BookingAvailabilityLoaded) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: 15, // 08:00 - 22:00
                        itemBuilder: (context, index) {
                          final hour = index + 8;
                          final slotTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            hour,
                          );
                          final isAvailable =
                              state.availabilityMap[hour] ?? false;
                          final isSelected = _selectedSlots.any(
                            (s) => s.hour == hour,
                          );

                          return InkWell(
                            onTap: isAvailable
                                ? () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedSlots.removeWhere(
                                          (s) => s.hour == hour,
                                        );
                                      } else {
                                        _selectedSlots.add(slotTime);
                                      }
                                    });
                                  }
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isAvailable
                                          ? Colors.white
                                          : Colors.grey[200]),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isAvailable
                                            ? Colors.black
                                            : Colors.grey[400]),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
              const SizedBox(height: 24),

              // 5. Customer Info
              const Text(
                'Nama Pelanggan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: Budi (Offline)',
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedCourt != null && _selectedSlots.isNotEmpty)
                      ? _submitBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan Booking Manual'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitBooking() {
    final sortedSlots = List<DateTime>.from(_selectedSlots)..sort();
    final startTime = sortedSlots.first;
    final endTime = sortedSlots.last.add(const Duration(hours: 1));
    final duration = sortedSlots.length;

    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _selectedVenue!.ownerId, // Set owner as creator
      venueId: _selectedVenue!.id,
      ownerId: _selectedVenue!.ownerId,
      courtId: _selectedCourt!.id,
      venueName: _selectedVenue!.name,
      courtName: _selectedCourt!.name,
      venueLocation: _selectedVenue!.address,
      sportType: _selectedCourt!.sportType,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      startTime: startTime,
      endTime: endTime,
      durationHours: duration,
      totalPrice: _selectedCourt!.hourlyPrice * duration,
      status: 'paid', // Manual booking is considered paid/confirmed immediately
      paymentStatus: 'paid',
      midtransOrderId: 'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
      participants: [
        PaymentParticipant(
          uid: _selectedVenue!.ownerId,
          name: _customerNameController.text,
          status: 'host',
          paymentStatusToHost: 'paid',
        ),
      ],
      participantIds: [_selectedVenue!.ownerId],
      createdAt: DateTime.now(),
    );

    context.read<BookingBloc>().add(BookingCreated(booking));
  }
}
