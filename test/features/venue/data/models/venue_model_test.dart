import 'package:flutter_test/flutter_test.dart';
import 'package:gsports/features/venue/data/models/venue_model.dart';
import 'package:gsports/features/venue/data/models/venue_holiday_model.dart';
import 'package:gsports/features/venue/domain/entities/venue_location.dart';

void main() {
  final tVenueModel = VenueModel(
    id: '1',
    ownerId: 'owner1',
    name: 'Venue 1',
    description: 'Description',
    address: 'Address',
    city: 'City',
    location: const VenueLocation(lat: 0.0, lng: 0.0),
    facilities: const ['Wifi'],
    photos: const ['photo1'],
    rating: 4.5,
    minPrice: 50000,
    holidays: [
      VenueHolidayModel(
        id: 'h1',
        name: 'Holiday',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 2),
      ),
    ],
  );

  group('VenueModel', () {
    test('toJson should return a valid map', () {
      final result = tVenueModel.toJson();
      expect(result['name'], 'Venue 1');
      expect(result['holidays'], isA<List>());
      expect((result['holidays'] as List).length, 1);
      expect((result['holidays'] as List)[0]['name'], 'Holiday');
    });

    test('fromJson should return a valid model', () {
      final json = {
        'id': '1',
        'ownerId': 'owner1',
        'name': 'Venue 1',
        'description': 'Description',
        'address': 'Address',
        'city': 'City',
        'location': {'lat': 0.0, 'lng': 0.0},
        'facilities': ['Wifi'],
        'photos': ['photo1'],
        'rating': 4.5,
        'minPrice': 50000,
        'holidays': [
          {
            'id': 'h1',
            'name': 'Holiday',
            'startDate': DateTime(2024, 1, 1).toIso8601String(),
            'endDate': DateTime(2024, 1, 2).toIso8601String(),
          },
        ],
      };
      final result = VenueModel.fromJson(json);
      expect(result.name, 'Venue 1');
      expect(result.holidays.length, 1);
      expect(result.holidays[0].name, 'Holiday');
    });
  });
}
