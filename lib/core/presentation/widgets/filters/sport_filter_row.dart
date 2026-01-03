import 'package:flutter/material.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';

class SportFilterRow extends StatelessWidget {
  final String? selectedSportId;
  final Function(String?) onSportSelected;

  const SportFilterRow({
    super.key,
    required this.selectedSportId,
    required this.onSportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Semua'),
              selected: selectedSportId == null,
              onSelected: (selected) {
                if (selected) onSportSelected(null);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selectedSportId == null
                    ? Colors.white
                    : AppColors.primary,
                fontWeight: selectedSportId == null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          ),
          ...AppConstants.sports.map((sport) {
            final isSelected = selectedSportId == sport.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(sport.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) onSportSelected(sport.id);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}
