import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class LocationService {
  static const String _baseUrl =
      'https://www.emsifa.com/api-wilayah-indonesia/api';

  // --- EMSifa API Methods ---

  Future<List<Map<String, dynamic>>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/provinces.json'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRegencies(String provinceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/regencies/$provinceId.json'),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDistricts(String regencyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/districts/$regencyId.json'),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- GPS & Geocoding Methods ---

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String?> getCityFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        // Prefer subAdministrativeArea (usually Regency/City in Indonesia) or locality
        return place.subAdministrativeArea ??
            place.locality ??
            place.administrativeArea;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
