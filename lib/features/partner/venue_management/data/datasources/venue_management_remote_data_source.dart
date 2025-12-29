import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/services/cloudinary_service.dart';
import 'package:gsports/features/venue/data/models/venue_model.dart';
import 'package:gsports/features/venue/data/models/court_model.dart';

abstract class VenueManagementRemoteDataSource {
  Future<List<VenueModel>> getMyVenues(String ownerId);
  Future<void> createVenue(VenueModel venue, List<File> images);
  Future<void> updateVenue(
    VenueModel venue, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  });
  Future<void> deleteVenue(String venueId);

  // Court Management
  Future<List<CourtModel>> getVenueCourts(String venueId);
  Future<void> addCourt(String venueId, CourtModel court, List<File> images);
  Future<void> updateCourt(
    String venueId,
    CourtModel court, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  });
  Future<void> deleteCourt(String venueId, String courtId);
}

@LazySingleton(as: VenueManagementRemoteDataSource)
class VenueManagementRemoteDataSourceImpl
    implements VenueManagementRemoteDataSource {
  final FirebaseFirestore firestore;
  final CloudinaryService cloudinaryService;

  VenueManagementRemoteDataSourceImpl(this.firestore, this.cloudinaryService);

  @override
  Future<List<VenueModel>> getMyVenues(String ownerId) async {
    try {
      final snapshot = await firestore
          .collection('venues')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return snapshot.docs.map((doc) => VenueModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createVenue(VenueModel venue, List<File> images) async {
    try {
      // 1. Upload images to Cloudinary
      final imageUrls = await cloudinaryService.uploadImages(
        images,
        folder: 'venues',
      );

      // 2. Prepare data
      final venueData = venue.toJson();
      venueData['photos'] = imageUrls;
      venueData['createdAt'] = FieldValue.serverTimestamp();

      // Convert location to GeoPoint
      venueData['location'] = GeoPoint(venue.location.lat, venue.location.lng);

      // 3. Save to Firestore
      await firestore.collection('venues').add(venueData);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateVenue(
    VenueModel venue, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  }) async {
    try {
      final venueDoc = firestore.collection('venues').doc(venue.id);

      // 1. Handle images
      List<String> currentPhotos = List<String>.from(venue.photos);

      // Remove URLs
      if (removedImageUrls != null) {
        currentPhotos.removeWhere((url) => removedImageUrls.contains(url));
      }

      // Upload new images
      if (newImages != null && newImages.isNotEmpty) {
        final newUrls = await cloudinaryService.uploadImages(
          newImages,
          folder: 'venues',
        );
        currentPhotos.addAll(newUrls);
      }

      // 2. Prepare update data
      final venueData = venue.toJson();
      venueData['photos'] = currentPhotos;
      venueData['location'] = GeoPoint(venue.location.lat, venue.location.lng);

      // Remove ID from data to avoid overwriting doc ID field if any
      venueData.remove('id');

      // 3. Update Firestore
      await venueDoc.update(venueData);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVenue(String venueId) async {
    try {
      await firestore.collection('venues').doc(venueId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CourtModel>> getVenueCourts(String venueId) async {
    try {
      final snapshot = await firestore
          .collection('venues')
          .doc(venueId)
          .collection('courts')
          .get();

      return snapshot.docs.map((doc) => CourtModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addCourt(
    String venueId,
    CourtModel court,
    List<File> images,
  ) async {
    try {
      // 1. Upload images
      final imageUrls = await cloudinaryService.uploadImages(
        images,
        folder: 'courts',
      );

      final data = court.toJson();
      data.remove('id');
      data['photos'] = imageUrls;

      await firestore
          .collection('venues')
          .doc(venueId)
          .collection('courts')
          .add(data);

      // Trigger minPrice and sportCategories update
      await _updateVenueMinPrice(venueId);
      await _updateVenueSportCategories(venueId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateCourt(
    String venueId,
    CourtModel court, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  }) async {
    try {
      List<String> currentPhotos = List<String>.from(court.photos);

      // Remove URLs
      if (removedImageUrls != null) {
        currentPhotos.removeWhere((url) => removedImageUrls.contains(url));
      }

      // Upload new images
      if (newImages != null && newImages.isNotEmpty) {
        final newUrls = await cloudinaryService.uploadImages(
          newImages,
          folder: 'courts',
        );
        currentPhotos.addAll(newUrls);
      }

      final data = court.toJson();
      data.remove('id');
      data['photos'] = currentPhotos;

      await firestore
          .collection('venues')
          .doc(venueId)
          .collection('courts')
          .doc(court.id)
          .update(data);

      // Trigger minPrice and sportCategories update
      await _updateVenueMinPrice(venueId);
      await _updateVenueSportCategories(venueId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteCourt(String venueId, String courtId) async {
    try {
      await firestore
          .collection('venues')
          .doc(venueId)
          .collection('courts')
          .doc(courtId)
          .delete();

      // Trigger minPrice and sportCategories update
      await _updateVenueMinPrice(venueId);
      await _updateVenueSportCategories(venueId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Private helper to calculate and update the minimum price of a venue based on its courts
  Future<void> _updateVenueMinPrice(String venueId) async {
    final courtsSnapshot = await firestore
        .collection('venues')
        .doc(venueId)
        .collection('courts')
        .get();

    if (courtsSnapshot.docs.isEmpty) {
      await firestore.collection('venues').doc(venueId).update({'minPrice': 0});
      return;
    }

    int minPrice = double.maxFinite.toInt();
    for (var doc in courtsSnapshot.docs) {
      final price = (doc.data()['hourlyPrice'] as num).toInt();
      if (price < minPrice) {
        minPrice = price;
      }
    }

    await firestore.collection('venues').doc(venueId).update({
      'minPrice': minPrice,
    });
  }

  /// Private helper to update the sport categories of a venue based on its courts
  Future<void> _updateVenueSportCategories(String venueId) async {
    final courtsSnapshot = await firestore
        .collection('venues')
        .doc(venueId)
        .collection('courts')
        .get();

    if (courtsSnapshot.docs.isEmpty) {
      await firestore.collection('venues').doc(venueId).update({
        'sportCategories': [],
      });
      return;
    }

    final Set<String> categories = {};
    for (var doc in courtsSnapshot.docs) {
      final sportType = doc.data()['sportType'] as String?;
      if (sportType != null && sportType.isNotEmpty) {
        categories.add(sportType);
      }
    }

    await firestore.collection('venues').doc(venueId).update({
      'sportCategories': categories.toList(),
    });
  }
}
