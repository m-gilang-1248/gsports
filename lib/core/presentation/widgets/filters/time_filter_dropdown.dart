import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/filter_constants.dart';
import 'package:intl/intl.dart';

class TimeFilterDropdown extends StatelessWidget {
  final TimeFilterPreset selectedPreset;
  final DateTime? customDate;
  final Function(TimeFilterPreset, DateTime?) onFilterChanged;

  const TimeFilterDropdown({
    super.key,
    required this.selectedPreset,
    this.customDate,
    required this.onFilterChanged,
  });

  String _getLabel() {
    switch (selectedPreset) {
      case TimeFilterPreset.all:
        return 'Semua Waktu';
      case TimeFilterPreset.thisWeek:
        return 'Minggu Ini';
      case TimeFilterPreset.thisMonth:
        return 'Bulan Ini';
      case TimeFilterPreset.customDate:
        return customDate != null
            ? DateFormat('dd MMM yyyy').format(customDate!)
            : 'Pilih Tanggal';
    }
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: customDate ?? DateTime.now(),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDate) {
                  onFilterChanged(TimeFilterPreset.customDate, newDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TimeFilterPreset>(
      onSelected: (preset) {
        if (preset == TimeFilterPreset.customDate) {
          _showDatePicker(context);
        } else {
          onFilterChanged(preset, null);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: TimeFilterPreset.all,
          child: Text('Semua Waktu'),
        ),
        const PopupMenuItem(
          value: TimeFilterPreset.thisWeek,
          child: Text('Minggu Ini'),
        ),
        const PopupMenuItem(
          value: TimeFilterPreset.thisMonth,
          child: Text('Bulan Ini'),
        ),
        const PopupMenuItem(
          value: TimeFilterPreset.customDate,
          child: Text('Pilih Tanggal...'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLabel(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
