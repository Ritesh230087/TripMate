import 'package:dio/dio.dart';

class OSLocationService {
  final Dio _dio = Dio();

  // 1. Get Address from Lat/Lng (Reverse Geocoding)
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
          'accept-language': 'en', // ✅ FORCE ENGLISH
        },
        options: Options(headers: {'User-Agent': 'com.tripmate.app'}),
      );

      if (response.statusCode == 200) {
        // Prefer 'road' or 'suburb', fallback to 'display_name'
        final addr = response.data['address'];
        String name = response.data['display_name'];
        
        // Try to make a shorter name if possible
        if (addr != null) {
          if (addr['road'] != null) name = addr['road'];
          else if (addr['suburb'] != null) name = addr['suburb'];
          else if (addr['city'] != null) name = addr['city'];
        }
        
        return name;
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
    return "Unknown Location";
  }

  // 2. Search Places (Autocomplete)
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
          'accept-language': 'en', // ✅ FORCE ENGLISH
          'countrycodes': 'np', // Limit to Nepal
        },
        options: Options(headers: {'User-Agent': 'com.tripmate.app'}),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print("Error searching places: $e");
    }
    return [];
  }
}