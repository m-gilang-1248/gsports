import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/core/presentation/widgets/custom_button.dart';
import 'package:gsports/core/presentation/widgets/custom_text_field.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/court_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';

class AddEditCourtPage extends StatefulWidget {
  final String venueId;
  final Court? court;

  const AddEditCourtPage({super.key, required this.venueId, this.court});

  @override
  State<AddEditCourtPage> createState() => _AddEditCourtPageState();
}

class _AddEditCourtPageState extends State<AddEditCourtPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late String _selectedSportId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.court?.name);
    _priceController = TextEditingController(
      text: widget.court?.hourlyPrice.toString(),
    );
    // Initialize with existing sport or default to first in registry
    if (widget.court != null) {
      // Try to find the matching ID, handle case sensitivity or fallback
      final existingId = widget.court!.sportType.toLowerCase();
      final match = AppConstants.sports.any((s) => s.id == existingId);
      _selectedSportId = match ? existingId : AppConstants.sports.first.id;
    } else {
      _selectedSportId = AppConstants.sports.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final court = Court(
      id: widget.court?.id ?? '', // ID handled by repo if new
      name: _nameController.text,
      sportType: _selectedSportId,
      hourlyPrice: int.tryParse(_priceController.text) ?? 0,
      isActive: true,
      surfaceType: widget.court?.surfaceType ?? 'Standard', // Default
      isIndoor: widget.court?.isIndoor ?? true, // Default
    );

    if (widget.court == null) {
      context.read<CourtManagementBloc>().add(
        AddCourtRequested(widget.venueId, court),
      );
    } else {
      context.read<CourtManagementBloc>().add(
        UpdateCourtRequested(widget.venueId, court),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.court == null ? 'Add Court' : 'Edit Court'),
      ),
      body: BlocListener<CourtManagementBloc, CourtManagementState>(
        listener: (context, state) {
          if (state is CourtActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is CourtManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Court Name',
                  hint: 'e.g. Lapangan 1',
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSportId,
                  decoration: const InputDecoration(
                    labelText: 'Sport Type',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.sports.map((sport) {
                    return DropdownMenuItem(
                      value: sport.id,
                      child: Row(
                        children: [
                          Icon(sport.icon, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(sport.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSportId = val!),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _priceController,
                  label: 'Hourly Price (Rp)',
                  hint: '50000',
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                BlocBuilder<CourtManagementBloc, CourtManagementState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Save Court',
                      isLoading: state is CourtManagementLoading,
                      onPressed: () => _submit(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
