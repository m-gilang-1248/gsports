import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/presentation/bloc/booking_bloc.dart';

class BookingTimeSlotGrid extends StatelessWidget {
  const BookingTimeSlotGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BookingAvailabilityLoaded) {
          if (state.isRefreshing) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final availabilityMap = state.availabilityMap;
          final selectedDate = state.selectedDate;
          final selectedSlots = state.selectedSlots;

          // Sort hours to display them in order
          final sortedHours = availabilityMap.keys.toList()..sort();

          if (sortedHours.isEmpty) {
            return const Center(child: Text('Tidak ada slot tersedia.'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: sortedHours.length,
            itemBuilder: (context, index) {
              final hour = sortedHours[index];
              final isAvailable = availabilityMap[hour] ?? false;

              // Determine if this slot is selected
              final isSelected = selectedSlots.any(
                (s) => s.hour == hour && s.day == selectedDate.day,
              );

              // Formatting hour "08:00"
              final timeString = '${hour.toString().padLeft(2, '0')}:00';

              return _TimeSlotCard(
                time: timeString,
                isAvailable: isAvailable,
                isSelected: isSelected,
                onTap: isAvailable
                    ? () {
                        final slotTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          hour,
                        );
                        context.read<BookingBloc>().add(
                          BookingSlotSelected(slotTime),
                        );
                      }
                    : null,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  final String time;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotCard({
    required this.time,
    required this.isAvailable,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Logic Color
    // Selected: Electric Blue, White Text
    // Available: White, Black Text, Black/Grey Border
    // Unavailable: Grey 300, Grey Text

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (!isAvailable) {
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.grey;
      borderColor = Colors.transparent;
    } else if (isSelected) {
      backgroundColor = AppColors.secondary;
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black;
      borderColor = Colors.grey[300]!;
    }

    return Material(
      color: Colors
          .transparent, // Ensure Material is transparent to show Ink beneath
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              time,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
