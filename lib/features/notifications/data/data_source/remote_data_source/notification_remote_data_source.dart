import 'package:dio/dio.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/features/notifications/data/model/notification_model.dart';
import 'package:tripmate/features/notifications/domain/entity/notification_entity.dart';

class NotificationRemoteDataSource {
  final Dio _dio;
  final TokenSharedPrefs _tokenSharedPrefs;

  NotificationRemoteDataSource(this._dio, this._tokenSharedPrefs);

  Future<String> _getToken() async {
    final tokenResult = await _tokenSharedPrefs.getToken();
    return tokenResult.getOrElse(() => '');
  }
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        ApiEndpoints.notifications,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load notifications");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Error fetching notifications");
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        "${ApiEndpoints.notifications}/unread-count",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Error getting count");
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await _getToken();
      await _dio.put(
        "${ApiEndpoints.notifications}/read/$notificationId",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Error marking read");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await _getToken();
      await _dio.put(
        "${ApiEndpoints.notifications}/read-all",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Error marking all read");
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final token = await _getToken();
      await _dio.delete(
        "${ApiEndpoints.notifications}/clear",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Error clearing notifications");
    }
  }
}