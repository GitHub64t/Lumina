import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response_parser.dart';
import '../models/profile_model.dart';

class ProfileRemoteDatasource {
  const ProfileRemoteDatasource(this._client);

  final DioClient _client;

  Future<ProfileModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.profile,
    );
    return ProfileModel.fromJson(_extractProfile(response.data));
  }

  /// UpdateProfileDto: { userId, firstName, lastName, dateOfBirth }
  Future<ProfileModel> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
  }) async {
    final body = {
      if (userId.isNotEmpty) 'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        'dateOfBirth': dateOfBirth,
    };

    try {
      final response = await _client.patch<Map<String, dynamic>>(
        ApiConstants.profile,
        data: body,
      );
      return ProfileModel.fromJson(_extractProfile(response.data));
    } on DioException catch (e) {
      // Fallback to POST if server returns 405 Method Not Allowed or 404
      if (e.response?.statusCode == 405 || e.response?.statusCode == 404) {
        final response = await _client.post<Map<String, dynamic>>(
          ApiConstants.profile,
          data: body,
        );
        return ProfileModel.fromJson(_extractProfile(response.data));
      }
      rethrow;
    }
  }

  /// ChangePasswordDto: { userId, oldPassword, newPassword }
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final body = {
      if (userId.isNotEmpty) 'userId': userId,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'currentPassword': oldPassword,
    };

    try {
      await _client.post(
        ApiConstants.changePassword,
        data: body,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 405 || e.response?.statusCode == 404) {
        await _client.patch(
          ApiConstants.changePassword,
          data: body,
        );
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> _extractProfile(Object? data) {
    final payload = ApiResponseParser.unwrap(data);
    if (payload is Map) {
      for (final key in ['user', 'profile']) {
        if (payload[key] is Map) {
          return Map<String, dynamic>.from(payload[key] as Map);
        }
      }
      return Map<String, dynamic>.from(payload);
    }
    return ApiResponseParser.map(data, nestedKey: 'profile');
  }
}
