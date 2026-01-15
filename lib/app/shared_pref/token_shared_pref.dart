import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmate/core/error/failure.dart';

class TokenSharedPrefs {
  final SharedPreferences _sharedPreferences;
  TokenSharedPrefs(this._sharedPreferences);

  Future<Either<Failure, void>> saveToken(String token) async {
    try {
      await _sharedPreferences.setString('token', token);
      return const Right(null);
    } catch (e) {
      return Left(SharedPrefsFailure(message: e.toString()));
    }
  }

  Future<void> saveUserId(String userId) async {
    await _sharedPreferences.setString('userId', userId);
  }

  // ✅ NEW: Get User ID
  Future<String> getUserId() async {
    return _sharedPreferences.getString('userId') ?? '';
  }

  Future<Either<Failure, String>> getToken() async {
    try {
      final token = _sharedPreferences.getString('token');
      return Right(token ?? '');
    } catch (e) {
      return Left(SharedPrefsFailure(message: e.toString()));
    }
  }

  Future<void> clear() async {
    await _sharedPreferences.remove('token');
    await _sharedPreferences.remove('userId');
  }
}