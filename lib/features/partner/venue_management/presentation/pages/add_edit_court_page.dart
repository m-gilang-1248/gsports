import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/core/presentation/widgets/custom_button.dart';
import 'package:gsports/core/presentation/widgets/custom_text_field.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/court_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:image_picker/image_picker.dart';

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
  late TextEditingController _descriptionController;
  late String _selectedSportId;

  final List<File> _newImages = [];
  List<String> _currentPhotos = [];
  final List<String> _removedPhotos = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.court?.name);
    _priceController = TextEditingController(
      text: widget.court?.hourlyPrice.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.court?.description,
    );

    _currentPhotos = widget.court?.photos != null
        ? List<String>.from(widget.court!.photos)
        : [];

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
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(String url) {
    setState(() {
      _currentPhotos.remove(url);
      _removedPhotos.add(url);
    });
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
      description: _descriptionController.text,
      photos: _currentPhotos,
    );

    if (widget.court == null) {
      context.read<CourtManagementBloc>().add(
        AddCourtRequested(widget.venueId, court, _newImages),
      );
    } else {
      context.read<CourtManagementBloc>().add(
        UpdateCourtRequested(
          widget.venueId,
          court,
          newImages: _newImages,
          removedImageUrls: _removedPhotos,
        ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Court Photos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildImagePicker(),
                const SizedBox(height: 24),
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
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe this court...',
                  maxLines: 3,
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

  Widget _buildImagePicker() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(
                    'Add Photo',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ..._currentPhotos.map(
            (url) => _buildImageItem(
              image: Image.network(url, fit: BoxFit.cover),
              onDelete: () => _removeExistingImage(url),
            ),
          ),
          ..._newImages.map(
            (file) => _buildImageItem(
              image: Image.file(file, fit: BoxFit.cover),
              onDelete: () => _removeNewImage(_newImages.indexOf(file)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem({
    required Widget image,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 100, height: 100, child: image),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
