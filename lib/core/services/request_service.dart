import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RequestService {
  final String baseUrl;
  final String token;

  RequestService({
    required this.baseUrl,
    required this.token,
  });

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> sendRideRequest({
    required String rideId,
    required LatLng meetingPoint,
    required LatLng dropPoint,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/request/send'),
      headers: _headers(),
      body: jsonEncode({
        'rideId': rideId,
        'meetingPoint': {
          'lat': meetingPoint.latitude,
          'lng': meetingPoint.longitude,
        },
        'dropPoint': {
          'lat': dropPoint.latitude,
          'lng': dropPoint.longitude,
        },
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send ride request');
    }
  }

  Future<void> acceptRequest(String requestId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/request/accept/$requestId'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept request');
    }
  }
}
