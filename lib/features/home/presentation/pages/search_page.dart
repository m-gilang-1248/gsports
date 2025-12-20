import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/presentation/widgets/venue_card.dart';
import 'package:gsports/features/venue/presentation/bloc/venue_bloc.dart';

class SearchPage extends StatefulWidget {
  final String? initialCategory;

  const SearchPage({super.key, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // If coming from Category Rail, set as query or filter logic (simplification: filter by query)
    if (widget.initialCategory != null) {
      _query = widget.initialCategory!;
      _searchController.text = _query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialCategory == null,
          decoration: InputDecoration(
            hintText: 'Cari nama lapangan atau olahraga...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _query = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: BlocBuilder<VenueBloc, VenueState>(
        builder: (context, state) {
          if (state is VenueListLoaded) {
            final filteredVenues = state.venues.where((venue) {
              final queryLower = _query.toLowerCase();
              if (queryLower.isEmpty) return true; // Show all if empty query (or just category)

              final matchName = venue.name.toLowerCase().contains(queryLower);
              final matchCity = venue.city.toLowerCase().contains(queryLower);
              final matchAddress = venue.address.toLowerCase().contains(queryLower);
              // Also check facilities as proxy for sports (e.g. 'badminton' in facilities or desc)
              final matchFacilities = venue.facilities.any((f) => f.toLowerCase().contains(queryLower));
              
              return matchName || matchCity || matchAddress || matchFacilities;
            }).toList();

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
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
