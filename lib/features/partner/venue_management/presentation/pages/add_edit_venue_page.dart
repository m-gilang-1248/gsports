import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/core/constants/facility_data.dart';
import 'package:gsports/core/presentation/widgets/custom_button.dart';
import 'package:gsports/core/presentation/widgets/custom_text_field.dart';
import 'package:gsports/core/services/location_service.dart';
import 'package:gsports/features/partner/venue_management/presentation/bloc/venue_management_bloc.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/venue_location.dart';
import 'package:image_picker/image_picker.dart';

class AddEditVenuePage extends StatefulWidget {
  final Venue? venue;

  const AddEditVenuePage({super.key, this.venue});

  @override
  State<AddEditVenuePage> createState() => _AddEditVenuePageState();
}

class _AddEditVenuePageState extends State<AddEditVenuePage> {
  final _formKey = GlobalKey<FormState>();
  final _locationService = LocationService();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;

  // Data Lists for Dropdowns
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _regencies = [];
  List<Map<String, dynamic>> _districts = [];

  // Selected Objects (Storing ID and Name)
  Map<String, dynamic>? _selectedProvince;
  Map<String, dynamic>? _selectedRegency;
  Map<String, dynamic>? _selectedDistrict;

  bool _isLoadingProvinces = false;
  bool _isLoadingRegencies = false;
  bool _isLoadingDistricts = false;

  // Time State
  TimeOfDay _openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);

  final List<File> _newImages = [];
  List<String> _currentPhotos = [];
  final List<String> _removedPhotos = [];

  final List<String> _availableFacilities = kFacilityIcons.keys.toList();

  List<String> _selectedFacilities = [];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.venue?.name);

    _addressController = TextEditingController(text: widget.venue?.address);

    _descriptionController = TextEditingController(
      text: widget.venue?.description,
    );

    _loadProvinces();

    if (widget.venue != null) {
      if (widget.venue!.operatingHours != null) {
        _initializeOperatingHours(widget.venue!.operatingHours!);
      }
    }

    _currentPhotos = widget.venue?.photos != null
        ? List<String>.from(widget.venue!.photos)
        : [];

    _selectedFacilities = widget.venue?.facilities != null
        ? List<String>.from(widget.venue!.facilities)
        : [];
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);
    final data = await _locationService.getProvinces();
    setState(() {
      _provinces = data;
      _isLoadingProvinces = false;
    });
  }

  Future<void> _onProvinceChanged(Map<String, dynamic>? province) async {
    if (province == null) return;
    setState(() {
      _selectedProvince = province;
      _selectedRegency = null;
      _selectedDistrict = null;
      _regencies = [];
      _districts = [];
      _isLoadingRegencies = true;
    });

    final data = await _locationService.getRegencies(province['id']);
    setState(() {
      _regencies = data;
      _isLoadingRegencies = false;
    });
  }

  Future<void> _onRegencyChanged(Map<String, dynamic>? regency) async {
    if (regency == null) return;
    setState(() {
      _selectedRegency = regency;
      _selectedDistrict = null;
      _districts = [];
      _isLoadingDistricts = true;
    });

    final data = await _locationService.getDistricts(regency['id']);
    setState(() {
      _districts = data;
      _isLoadingDistricts = false;
    });
  }

  void _initializeOperatingHours(Map<String, dynamic> hours) {
    if (hours.containsKey('Monday')) {
      final monday = hours['Monday'] as Map<String, dynamic>;
      _openTime = _parseTime(monday['open'] ?? '08:00');
      _closeTime = _parseTime(monday['close'] ?? '22:00');
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
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

  Future<void> _selectTime(bool isOpenTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_newImages.isEmpty && _currentPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one photo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedProvince == null ||
        _selectedRegency == null ||
        _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select complete location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final openStr = _formatTime(_openTime);
    final closeStr = _formatTime(_closeTime);
    final operatingHours = {
      for (var day in [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ])
        day: {'open': openStr, 'close': closeStr, 'isOpen': true},
    };

    final venue = Venue(
      id: widget.venue?.id ?? '',
      ownerId: user.uid,
      name: _nameController.text,
      description: _descriptionController.text,
      address:
          '${_addressController.text}, ${_selectedDistrict!['name']}, ${_selectedRegency!['name']}, ${_selectedProvince!['name']}',
      city: _selectedRegency!['name'],
      location:
          widget.venue?.location ??
          const VenueLocation(lat: -6.200000, lng: 106.816666),
      facilities: _selectedFacilities,
      photos: _currentPhotos,
      rating: widget.venue?.rating ?? 0.0,
      minPrice: 0,
      isVerified: widget.venue?.isVerified ?? false,
      operatingHours: operatingHours,
    );

    if (widget.venue == null) {
      context.read<VenueManagementBloc>().add(
        CreateVenueRequested(venue, _newImages),
      );
    } else {
      context.read<VenueManagementBloc>().add(
        UpdateVenueRequested(
          venue,
          newImages: _newImages,
          removedImageUrls: _removedPhotos,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<VenueManagementBloc>(),
      child: BlocConsumer<VenueManagementBloc, VenueManagementState>(
        listener: (context, state) {
          if (state is VenueActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(true);
          } else if (state is VenueManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is VenueManagementLoading;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.venue == null ? 'Add New Venue' : 'Edit Venue',
              ),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Venue Photos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    CustomTextField(
                      controller: _nameController,
                      label: 'Venue Name',
                      hint: 'e.g. GOR Badminton Kemang',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // --- LOCATION SECTION (API BASED) ---
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildApiLocationDropdowns(),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      hint: 'Jl. Kemang Raya No. 10...',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // --- OPERATING HOURS SECTION ---
                    const Text(
                      'Operating Hours',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimePickers(),
                    const SizedBox(height: 24),

                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your venue facilities, rules, etc.',
                      maxLines: 4,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Facilities',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFacilitiesChips(),
                    const SizedBox(height: 40),

                    CustomButton(
                      text: widget.venue == null
                          ? 'Create Venue'
                          : 'Save Changes',
                      isLoading: isLoading,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApiLocationDropdowns() {
    return Column(
      children: [
        // Province
        _buildDropdown(
          label: 'Province',
          value: _selectedProvince,
          items: _provinces,
          isLoading: _isLoadingProvinces,
          onChanged: (val) => _onProvinceChanged(val),
        ),
        const SizedBox(height: 16),
        // Regency
        _buildDropdown(
          label: 'City / Regency',
          value: _selectedRegency,
          items: _regencies,
          isLoading: _isLoadingRegencies,
          onChanged: _selectedProvince == null
              ? null
              : (val) => _onRegencyChanged(val),
        ),
        const SizedBox(height: 16),
        // District
        _buildDropdown(
          label: 'District (Kecamatan)',
          value: _selectedDistrict,
          items: _districts,
          isLoading: _isLoadingDistricts,
          onChanged: _selectedRegency == null
              ? null
              : (val) {
                  setState(() => _selectedDistrict = val);
                },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required Map<String, dynamic>? value,
    required List<Map<String, dynamic>> items,
    required bool isLoading,
    required Function(Map<String, dynamic>?)? onChanged,
  }) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      initialValue: value,
      isExpanded: true,
      decoration: _dropdownDecoration(label).copyWith(
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item['name']));
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(child: _buildTimeField('Opening Time', _openTime, true)),
        const SizedBox(width: 16),
        Expanded(child: _buildTimeField('Closing Time', _closeTime, false)),
      ],
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time, bool isOpenTime) {
    return InkWell(
      onTap: () => _selectTime(isOpenTime),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildFacilitiesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableFacilities.map((facility) {
        final isSelected = _selectedFacilities.contains(facility);
        return FilterChip(
          label: Text(facility),
          avatar: Icon(
            kFacilityIcons[facility] ?? Icons.check_circle,
            size: 18,
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedFacilities.add(facility);
              } else {
                _selectedFacilities.remove(facility);
              }
            });
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundColor: Colors.white,
          checkmarkColor: AppColors.primary,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}
