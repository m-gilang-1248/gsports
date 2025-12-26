import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/features/booking/data/models/booking_model.dart';

abstract class PartnerRemoteDataSource {
  Future<List<BookingModel>> getPartnerBookings(String uid);
}

@LazySingleton(as: PartnerRemoteDataSource)
class PartnerRemoteDataSourceImpl implements PartnerRemoteDataSource {
  final FirebaseFirestore firestore;

  PartnerRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<BookingModel>> getPartnerBookings(String uid) async {
    try {
      // Query bookings where ownerId == uid
      final snapshot = await firestore
          .collection('bookings')
          .where('ownerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
