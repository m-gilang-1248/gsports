import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _baseUrl = 'https://www.emsifa.com/api-wilayah-indonesia/api';

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
      final response = await http.get(Uri.parse('$_baseUrl/regencies/$provinceId.json'));
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
      final response = await http.get(Uri.parse('$_baseUrl/districts/$regencyId.json'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
