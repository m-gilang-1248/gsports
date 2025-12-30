import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/presentation/widgets/venue_card.dart';
import 'package:gsports/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:gsports/injection_container.dart';

class SavedVenuesPage extends StatelessWidget {
  const SavedVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorit Saya')),
        body: const Center(child: Text('Silakan login untuk melihat favorit.')),
      );
    }

    return BlocProvider(
      create: (context) =>
          getIt<FavoritesBloc>()..add(FetchFavorites(user.uid)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Favorit Saya')),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              if (state.venues.isEmpty) {
                return const Center(child: Text('Belum ada venue favorit.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.venues.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final venue = state.venues[index];
                  return VenueCard(
                    venue: venue,
                    onTap: () {
                      context.pushNamed(
                        'venueDetail',
                        pathParameters: {'id': venue.id},
                      );
                    },
                  );
                },
              );
            } else if (state is FavoritesError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
