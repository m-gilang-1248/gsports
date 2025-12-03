import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/utils/venue_seeder.dart';
import 'package:gsports/features/venue/presentation/bloc/venue_bloc.dart';
import 'package:gsports/features/venue/presentation/widgets/venue_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Trigger fetch when Home is opened
    context.read<VenueBloc>().add(VenueFetchListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gsports'),
        actions: [
          // Temporary Seed Button
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Seed Data',
            onPressed: () async {
              try {
                await VenueSeeder.seedVenues();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data seeded. Pull to refresh or wait.'),
                    ),
                  );
                  context.read<VenueBloc>().add(VenueFetchListRequested());
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error seeding data: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<VenueBloc, VenueState>(
        buildWhen: (previous, current) =>
            current is VenueListLoaded ||
            current is VenueLoading ||
            current is VenueError,
        builder: (context, state) {
          if (state is VenueLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VenueError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VenueBloc>().add(VenueFetchListRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is VenueListLoaded) {
            if (state.venues.isEmpty) {
              return const Center(child: Text('No venues found.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<VenueBloc>().add(VenueFetchListRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.venues.length,
                itemBuilder: (context, index) {
                  final venue = state.venues[index];
                  return VenueCard(
                    venue: venue,
                    onTap: () {
                      context.push('/venue/${venue.id}');
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
