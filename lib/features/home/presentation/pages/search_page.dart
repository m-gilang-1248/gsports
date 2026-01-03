import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/presentation/widgets/venue_card.dart';
import 'package:gsports/features/venue/presentation/bloc/venue_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class SearchPage extends StatefulWidget {
  final String? initialCategory;

  const SearchPage({super.key, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  final _searchSubject = PublishSubject<String>();
  StreamSubscription? _searchSubscription;

  String _query = '';
  String? _selectedSport;
  String? _selectedCity;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    if (widget.initialCategory != null) {
      _query = '';
      _selectedSport = widget.initialCategory;
      _searchController.text = _query;
    }

    // Debounce search input
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen((query) {
          _triggerSearch();
        });

    // Ensure Venue List is loaded
    final bloc = context.read<VenueBloc>();
    if (bloc.state is! VenueListLoaded) {
      bloc.add(VenueFetchListRequested());
    } else {
      // If already loaded, trigger initial filter
      _triggerSearch();
    }
  }

  void _triggerSearch() {
    context.read<VenueBloc>().add(
      VenueSearchRequested(
        query: _query,
        sportType: _selectedSport,
        city: _selectedCity,
        date: _selectedDate,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    _searchSubscription?.cancel();
    super.dispose();
  }

  void _showFilterBottomSheet(VenueListLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedSport = null;
                            _selectedCity = null;
                            _selectedDate = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Olahraga',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Futsal', 'Badminton', 'Basket', 'Tenis', 'Voli']
                        .map((sport) {
                          final isSelected = _selectedSport == sport;
                          return ChoiceChip(
                            label: Text(sport),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedSport = selected ? sport : null;
                              });
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        })
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kota',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue:
                        (state.availableCities.contains(_selectedCity))
                        ? _selectedCity
                        : null,
                    hint: const Text('Pilih Kota'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.neutral,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: state.availableCities.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        _selectedCity = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tanggal Main',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setModalState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Pilih Tanggal'
                                : DateFormat(
                                    'EEEE, d MMM yyyy',
                                    'id_ID',
                                  ).format(_selectedDate!),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _triggerSearch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: AppColors.neutral,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: widget.initialCategory == null,
            decoration: InputDecoration(
              hintText: 'Cari nama lapangan...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _query = '';
                          _searchController.clear();
                          _searchSubject.add('');
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
              _searchSubject.add(value);
            },
          ),
        ),
        actions: [
          BlocBuilder<VenueBloc, VenueState>(
            builder: (context, state) {
              if (state is VenueListLoaded) {
                return IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color:
                        (_selectedSport != null ||
                            _selectedCity != null ||
                            _selectedDate != null)
                        ? AppColors.primary
                        : Colors.black,
                  ),
                  onPressed: () => _showFilterBottomSheet(state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<VenueBloc, VenueState>(
        builder: (context, state) {
          if (state is VenueListLoaded) {
            final filteredVenues = state.filteredVenues;

            if (filteredVenues.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada hasil ditemukan',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (_selectedSport != null ||
                        _selectedCity != null ||
                        _selectedDate != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedSport = null;
                            _selectedCity = null;
                            _selectedDate = null;
                          });
                          _triggerSearch();
                        },
                        child: const Text('Hapus Filter'),
                      ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredVenues.length,
              itemBuilder: (context, index) {
                final venue = filteredVenues[index];
                return VenueCard(
                  venue: venue,
                  onTap: () {
                    context.push('/venue/${venue.id}');
                  },
                );
              },
            );
          } else if (state is VenueListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VenueError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
