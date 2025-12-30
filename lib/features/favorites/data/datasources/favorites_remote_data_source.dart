import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/features/venue/data/models/venue_model.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

abstract class FavoritesRemoteDataSource {
  Future<bool> isFavorite(String userId, String venueId);
  Future<void> toggleFavorite(String userId, Venue venue);
  Future<List<VenueModel>> getFavoriteVenues(String userId);
}

@LazySingleton(as: FavoritesRemoteDataSource)
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoritesRemoteDataSourceImpl(this.firestore);

  @override
  Future<bool> isFavorite(String userId, String venueId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(venueId)
          .get();
      return doc.exists;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> toggleFavorite(String userId, Venue venue) async {
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(venue.id);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        // Save minimal venue data for list display
        final venueModel = VenueModel(
          id: venue.id,
          ownerId: venue.ownerId,
          name: venue.name,
          description: venue.description,
          address: venue.address,
          city: venue.city,
          location: venue.location,
          facilities: venue.facilities,
          photos: venue.photos,
          rating: venue.rating,
          minPrice: venue.minPrice,
          isVerified: venue.isVerified,
          operatingHours: venue.operatingHours,
        );
        await docRef.set(venueModel.toJson());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<VenueModel>> getFavoriteVenues(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return snapshot.docs
          .map((doc) => VenueModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
