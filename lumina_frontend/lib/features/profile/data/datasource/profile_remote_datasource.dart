import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileRemoteDatasource {
  const ProfileRemoteDatasource(this._client);

  final DioClient _client;

  Future<ProfileModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.profile,
    );
    return ProfileModel.fromJson(_extractProfile(response.data as Map));
  }

  /// UpdateProfileDto: { userId, firstName, lastName, dateOfBirth }
  Future<ProfileModel> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.profile,
      data: {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': ?dateOfBirth,
      },
    );
    return ProfileModel.fromJson(_extractProfile(response.data as Map));
  }

  /// ChangePasswordDto: { userId, oldPassword, newPassword }
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) {
    return _client.post(
      ApiConstants.changePassword,
      data: {
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Map<String, dynamic> _extractProfile(Map<dynamic, dynamic> data) {
    final map = Map<String, dynamic>.from(data);
    final payload = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : map;
    return payload['profile'] is Map
        ? Map<String, dynamic>.from(payload['profile'] as Map)
        : payload;
  }
}
