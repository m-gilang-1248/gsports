import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsports/features/venue/data/models/court_model.dart';
import 'package:gsports/features/venue/data/models/venue_model.dart';
import 'package:gsports/features/venue/domain/entities/venue_location.dart';

class VenueSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedVenues() async {
    try {
      final collection = _firestore.collection('venues');
      final snapshot = await collection.limit(1).get();

      // If venues already exist, do nothing
      if (snapshot.docs.isNotEmpty) {
        return;
      }

      const dummyOwnerId = 'SYSTEM_SEED';

      // Data Dummy 1: GOR Badminton Juara
      final venue1 = VenueModel(
        id: '', // Auto ID
        ownerId: dummyOwnerId,
        name: 'GOR Badminton Juara',
        description:
            'GOR Badminton terbaik di Jakarta Selatan dengan fasilitas lengkap dan parkir luas.',
        address: 'Jl. Fatmawati No. 10',
        city: 'Jakarta Selatan',
        location: const VenueLocation(lat: -6.295424, lng: 106.795134),
        facilities: const ['Parking', 'Wifi', 'Toilet', 'Mosque', 'Canteen'],
        photos: const [
          'https://images.unsplash.com/photo-1626224583764-847649623db6?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          'https://images.unsplash.com/photo-1521537634581-0dced2fee2ef?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          'https://images.unsplash.com/photo-1534158914592-062992fbe900?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        ],
        rating: 4.8,
        minPrice: 50000,
        isVerified: true,
      );

      final venueRef1 = await collection.add(venue1.toJson());

      // Courts for Venue 1
      final courts1 = [
        const CourtModel(
          id: '',
          name: 'Lapangan 1 (Karpet)',
          sportType: 'Badminton',
          hourlyPrice: 50000,
        ),
        const CourtModel(
          id: '',
          name: 'Lapangan 2 (Karpet)',
          sportType: 'Badminton',
          hourlyPrice: 50000,
        ),
        const CourtModel(
          id: '',
          name: 'Lapangan 3 (Kayu)',
          sportType: 'Badminton',
          hourlyPrice: 40000,
        ),
      ];

      for (final court in courts1) {
        await venueRef1.collection('courts').add(court.toJson());
      }

      // Data Dummy 2: Futsal Center Tebet
      final venue2 = VenueModel(
        id: '',
        ownerId: dummyOwnerId,
        name: 'Futsal Center Tebet',
        description:
            'Lapangan futsal rumput sintetis kualitas FIFA. Buka 24 jam.',
        address: 'Jl. Tebet Raya No. 45',
        city: 'Jakarta Selatan',
        location: const VenueLocation(lat: -6.226959, lng: 106.852123),
        facilities: const ['Parking', 'Shower', 'Locker', 'Wifi'],
        photos: const [
          'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        ],
        rating: 4.5,
        minPrice: 120000,
        isVerified: true,
      );

      final venueRef2 = await collection.add(venue2.toJson());

      final courts2 = [
        const CourtModel(
          id: '',
          name: 'Lapangan A (Sintetis)',
          sportType: 'Futsal',
          hourlyPrice: 120000,
        ),
        const CourtModel(
          id: '',
          name: 'Lapangan B (Vinyl)',
          sportType: 'Futsal',
          hourlyPrice: 150000,
        ),
      ];

      for (final court in courts2) {
        await venueRef2.collection('courts').add(court.toJson());
      }

      // Data Dummy 3: Tennis Court Senayan
      final venue3 = VenueModel(
        id: '',
        ownerId: dummyOwnerId,
        name: 'Tennis Court Senayan',
        description: 'Lapangan tenis outdoor dan indoor standar turnamen.',
        address: 'Gelora Bung Karno',
        city: 'Jakarta Pusat',
        location: const VenueLocation(lat: -6.218480, lng: 106.802549),
        facilities: const ['Parking', 'Shower', 'Pro Shop', 'Coach'],
        photos: const [
          'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          'https://images.unsplash.com/photo-1622279457486-62dcc4a4bd13?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        ],
        rating: 4.9,
        minPrice: 150000,
        isVerified: true,
      );

      final venueRef3 = await collection.add(venue3.toJson());

      final courts3 = [
        const CourtModel(
          id: '',
          name: 'Court 1 (Hard)',
          sportType: 'Tennis',
          hourlyPrice: 150000,
        ),
        const CourtModel(
          id: '',
          name: 'Court 2 (Clay)',
          sportType: 'Tennis',
          hourlyPrice: 180000,
        ),
      ];

      for (final court in courts3) {
        await venueRef3.collection('courts').add(court.toJson());
      }
    } catch (e) {
      rethrow;
    }
  }
}