import 'package:dio/dio.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/core/network/api_service.dart';
import 'package:tripmate/features/ride/data/model/ride_model.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/domain/entity/ride_request_entity.dart';

class RideRemoteDataSource {
  final ApiService _apiService;
  final TokenSharedPrefs _tokenSharedPrefs;

  RideRemoteDataSource(this._apiService, this._tokenSharedPrefs);

  Future<String> _getToken() async {
    final tokenResult = await _tokenSharedPrefs.getToken();
    return tokenResult.getOrElse(() => '');
  }

  Future<void> publishRide(RideEntity ride) async {
    try {
      final token = await _getToken();
      final data = {
        "fromLocation": ride.from,
        "fromLatLng": {"lat": ride.fromLatLng.latitude, "lng": ride.fromLatLng.longitude},
        "toLocation": ride.to,
        "toLatLng": {"lat": ride.toLatLng.latitude, "lng": ride.toLatLng.longitude},
        "date": ride.date,
        "time": ride.time,
        "price": ride.price,
        "routePath": ride.routePath?.map((e) => {"lat": e.latitude, "lng": e.longitude}).toList(),
      };

      await _apiService.dio.post(
        "${ApiEndpoints.baseUrl}rider/publish",
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<RideEntity>> searchRides(double pLat, double pLng, double dLat, double dLng, String date, String time) async {
    try {
      final token = await _getToken();
      final response = await _apiService.dio.post(
        "${ApiEndpoints.baseUrl}rider/search",
        data: {
          "pickupLat": pLat, "pickupLng": pLng,
          "dropoffLat": dLat, "dropoffLng": dLng,
          "date": date, "time": time
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => RideModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to fetch rides");
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> sendRequest({
    required String rideId,
    required String riderId,
    required double meetingPointLat,
    required double meetingPointLng,
    required double dropPointLat,
    required double dropPointLng,
    required double passengerPickupLat,
    required double passengerPickupLng,
    required double passengerDropoffLat,
    required double passengerDropoffLng,
    required int pickupDetour,
    required int pickupWalk,
    required int dropoffDetour,
    required int dropoffWalk,
    required String matchType,
  }) async {
    try {
      final token = await _getToken();
      final response = await _apiService.dio.post(
        "${ApiEndpoints.baseUrl}request/send",
        data: {
          "rideId": rideId,
          "riderId": riderId,
          "meetingPoint": {"lat": meetingPointLat, "lng": meetingPointLng},
          "dropPoint": {"lat": dropPointLat, "lng": dropPointLng},
          "passengerActualPickup": {"lat": passengerPickupLat, "lng": passengerPickupLng},
          "passengerActualDropoff": {"lat": passengerDropoffLat, "lng": passengerDropoffLng},
          "pickupDetour": pickupDetour,
          "pickupWalk": pickupWalk,
          "dropoffDetour": dropoffDetour,
          "dropoffWalk": dropoffWalk,
          "matchType": matchType
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 201) throw Exception("Failed to send request");
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<RideRequestEntity>> getIncomingRequests() async {
    try {
      final token = await _getToken();
      final response = await _apiService.dio.get(
        "${ApiEndpoints.baseUrl}request/rider/incoming",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) {
          final passenger = item['passengerId'] ?? {};
          final ride = (item['rideId'] is Map) ? item['rideId'] : {};

          return RideRequestEntity(
            id: item['_id'].toString(),
            passengerName: passenger['fullName'] ?? "Unknown",
            passengerImage: passenger['profilePic'] ?? "",
            passengerRating: (passenger['passengerRating'] as num?)?.toDouble() ?? 0.0,
            passengerTags: passenger['passengerFeedbackTags'] != null ? List<String>.from(passenger['passengerFeedbackTags']) : [],
            fromLocation: ride['fromLocation'] ?? "Unknown",
            toLocation: ride['toLocation'] ?? "Unknown",
            date: ride['date'] ?? "",
            time: ride['time'] ?? "",
            price: (ride['price'] as num?)?.toDouble() ?? 0.0,
            pickupDetour: (item['pickupDetour'] as num?)?.toInt() ?? 0,
            pickupWalk: (item['pickupWalk'] as num?)?.toInt() ?? 0,
            dropoffDetour: (item['dropoffDetour'] as num?)?.toInt() ?? 0,
            dropoffWalk: (item['dropoffWalk'] as num?)?.toInt() ?? 0,
            matchType: item['matchType'] ?? 'exact',
          );
        }).toList();
      } else { throw Exception("Failed to load requests"); }
    } on DioException catch (e) { throw Exception(e.message); }
  }

  Future<void> respondToRequest(String requestId, String status) async {
    try {
      final token = await _getToken();
      await _apiService.dio.put(
        "${ApiEndpoints.baseUrl}request/respond/$requestId",
        data: {"status": status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) { throw Exception(e.message); }
  }

  Future<void> updateRideStatus(String rideId, String newStatus) async {
    try {
      final token = await _getToken();
      await _apiService.dio.put(
        "${ApiEndpoints.baseUrl}rider/status/$rideId",
        data: { "status": newStatus },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) { throw Exception(e.message); }
  }

  Future<void> confirmPayment(String rideId) async {
    try {
      final token = await _getToken();
      await _apiService.dio.put(
        "${ApiEndpoints.baseUrl}rider/payment/confirm/$rideId",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) { throw Exception(e.message); }
  }

Future<void> processPayment({required String rideId, required String method, String? transactionId}) async {
  try {
    final token = (await _tokenSharedPrefs.getToken()).getOrElse(() => '');
    await _apiService.dio.post(
      "${ApiEndpoints.baseUrl}rider/payment/process",
      data: {"rideId": rideId, "method": method, "transactionId": transactionId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  } on DioException catch (e) { throw Exception(e.message); }
}

Future<void> submitFeedback({
  required String rideId,
  required double rating,
  required List<String> tags,
  required String targetRole,
}) async {
  try {
    final tokenResult = await _tokenSharedPrefs.getToken();
    final token = tokenResult.getOrElse(() => '');

    final response = await _apiService.dio.post(
      "${ApiEndpoints.baseUrl}rider/feedback/submit", // Matches Backend Fix
      data: {
        "rideId": rideId,
        "rating": rating,
        "tags": tags,
        "targetRole": targetRole,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? "Feedback failed");
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? "Feedback error");
  }
}

  Future<List<RideEntity>> getMyRides() async {
    try {
      final token = await _getToken();
      final response = await _apiService.dio.get(
        "${ApiEndpoints.baseUrl}rider/my-rides",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => RideModel.fromJson(item)).toList();
      } else { throw Exception("Failed to load rides"); }
    } on DioException catch (e) { throw Exception(e.message); }
  }

  Future<List<RideEntity>> getPassengerUpcomingRides() async {
    try {
      final token = await _getToken();
      final response = await _apiService.dio.get(
        "${ApiEndpoints.baseUrl}rider/passenger/upcoming",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => RideModel.fromJson(item)).toList();
      } else { return []; }
    } on DioException catch (e) { throw Exception(e.message); }
  }

  Future<void> deleteRide(String rideId) async {
    try {
      final tokenResult = await _tokenSharedPrefs.getToken();
      final token = tokenResult.getOrElse(() => '');
      
      await _apiService.dio.delete(
        "${ApiEndpoints.baseUrl}rider/delete/$rideId",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updateRide(String rideId, String date, String time, double price) async {
    try {
      final tokenResult = await _tokenSharedPrefs.getToken();
      final token = tokenResult.getOrElse(() => '');
      
      final response = await _apiService.dio.put(
        "${ApiEndpoints.baseUrl}rider/update/$rideId",
        data: {
          "date": date,
          "time": time,
          "price": price
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? "Failed to update");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

Future<void> cancelRide(String rideId, String reason) async {
  try {
    final tokenResult = await _tokenSharedPrefs.getToken();
    final token = tokenResult.getOrElse(() => '');
    
    final response = await _apiService.dio.put(
      "${ApiEndpoints.baseUrl}rider/cancel/$rideId",
      data: {"reason": reason},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? "Cancellation failed");
    }
  } on DioException catch (e) {
    final msg = e.response?.data['message'] ?? e.message;
    throw Exception(msg);
  }
}

Future<List<RideEntity>> getRiderHistory() async {
  try {
    final token = (await _tokenSharedPrefs.getToken()).getOrElse(() => '');
    final response = await _apiService.dio.get(
      "${ApiEndpoints.baseUrl}rider/history/rider",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => RideModel.fromJson(item)).toList();
    }
    return [];
  } on DioException catch (e) {
    throw Exception(e.message);
  }
}

Future<List<RideEntity>> getPassengerHistory() async {
  try {
    final token = (await _tokenSharedPrefs.getToken()).getOrElse(() => '');
    final response = await _apiService.dio.get(
      "${ApiEndpoints.baseUrl}rider/history/passenger",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => RideModel.fromJson(item)).toList();
    }
    return [];
  } on DioException catch (e) {
    throw Exception(e.message);
  }
}

Future<List<dynamic>> getPassengerRequests() async {
  try {
    final token = (await _tokenSharedPrefs.getToken()).getOrElse(() => '');
    final response = await _apiService.dio.get(
      "${ApiEndpoints.baseUrl}request/passenger/my-requests",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data; 
  } on DioException catch (e) {
    throw Exception(e.message);
  }
}

Future<void> markRequestAsViewed(String requestId) async {
  try {
    final tokenResult = await _tokenSharedPrefs.getToken();
    final token = tokenResult.getOrElse(() => '');
    
    await _apiService.dio.put(
      "${ApiEndpoints.baseUrl}request/viewed/$requestId",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  } on DioException catch (e) {
    print("Dio Error Status: ${e.response?.statusCode}");
    print("Dio Error Data: ${e.response?.data}");
    throw Exception(e.response?.data['message'] ?? "Failed to clear request");
  }
}

Future<Map<String, dynamic>> getSidebarCounts() async {
  try {
    final tokenResult = await _tokenSharedPrefs.getToken();
    final token = tokenResult.getOrElse(() => '');

    final response = await _apiService.dio.get(
      "${ApiEndpoints.baseUrl}rider/sidebar/counts",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  } catch (e) {
    throw Exception("Failed to fetch counts");
  }
}
}