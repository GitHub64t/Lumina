import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/preferences_model.dart';

class PreferencesRemoteDatasource {
  const PreferencesRemoteDatasource(this._client);

  final DioClient _client;

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _client.get<dynamic>(ApiConstants.categories);
    final payload = response.data;
    final envelope = payload is Map && payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    final list = envelope is Map
        ? envelope['categories'] ?? envelope['items'] ?? envelope['data']
        : envelope;
    return (list as List)
        .map(
          (item) =>
              CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<PreferencesModel> getPreferences() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.preferences,
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final envelope = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final payload = envelope['preferences'] is Map
        ? Map<String, dynamic>.from(envelope['preferences'] as Map)
        : envelope;
    return PreferencesModel.fromJson(payload);
  }

  /// SaveUserPreferencesDto: { userId, categoryids }
  Future<PreferencesModel> savePreferences(
    String userId,
    List<String> categoryIds,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.preferences,
      data: {'userId': userId, 'categoryids': categoryIds},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final envelope = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final payload = envelope['preferences'] is Map
        ? Map<String, dynamic>.from(envelope['preferences'] as Map)
        : envelope;
    return PreferencesModel.fromJson(payload);
  }
}
