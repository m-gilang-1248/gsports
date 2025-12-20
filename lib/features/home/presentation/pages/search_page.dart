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
    
    // Fix: Trigger search immediately if category is present
    if (widget.initialCategory != null) {
      _query = widget.initialCategory!;
      _searchController.text = _query;
    }
    
    // Ensure Venue List is loaded if not already
    final bloc = context.read<VenueBloc>();
    if (bloc.state is! VenueListLoaded) {
      bloc.add(VenueFetchListRequested());
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
              hintText: 'Cari nama lapangan atau olahraga...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _query = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
        ),
      ),
      body: BlocBuilder<VenueBloc, VenueState>(
        builder: (context, state) {
          if (state is VenueListLoaded) {
            final filteredVenues = state.venues.where((venue) {
              final queryLower = _query.toLowerCase();
              if (queryLower.isEmpty) return true;

              final matchName = venue.name.toLowerCase().contains(queryLower);
              final matchCity = venue.city.toLowerCase().contains(queryLower);
              final matchAddress = venue.address.toLowerCase().contains(queryLower);
              final matchFacilities = venue.facilities.any((f) => f.toLowerCase().contains(queryLower));
              
              // Simple proxy for category matching since we don't have explicit category field yet
              final matchCategory = widget.initialCategory != null && 
                  (matchName || matchFacilities || venue.name.toLowerCase().contains(widget.initialCategory!.toLowerCase()));

              return matchName || matchCity || matchAddress || matchFacilities || matchCategory;
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