import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/court_model.dart';
import '../models/venue_model.dart';

abstract class VenueRemoteDataSource {
  Future<List<VenueModel>> getVenues();
  Future<VenueModel> getVenueDetail(String venueId);
  Future<List<CourtModel>> getVenueCourts(String venueId);
}

@LazySingleton(as: VenueRemoteDataSource)
class VenueRemoteDataSourceImpl implements VenueRemoteDataSource {
  final FirebaseFirestore firestore;

  VenueRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<VenueModel>> getVenues() async {
    final querySnapshot = await firestore.collection('venues').get();
    return querySnapshot.docs
        .map((doc) => VenueModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<VenueModel> getVenueDetail(String venueId) async {
    final docSnapshot = await firestore.collection('venues').doc(venueId).get();
    if (!docSnapshot.exists) {
      throw Exception('Venue not found');
    }
    return VenueModel.fromFirestore(docSnapshot);
  }

  @override
  Future<List<CourtModel>> getVenueCourts(String venueId) async {
    final querySnapshot = await firestore
        .collection('venues')
        .doc(venueId)
        .collection('courts')
        .get();
    return querySnapshot.docs
        .map((doc) => CourtModel.fromFirestore(doc))
        .toList();
  }
}
