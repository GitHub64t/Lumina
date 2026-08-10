import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response_parser.dart';
import '../models/category_model.dart';
import '../models/preferences_model.dart';

class PreferencesRemoteDatasource {
  const PreferencesRemoteDatasource(this._client);

  final DioClient _client;

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _client.get<dynamic>(ApiConstants.categories);
    return ApiResponseParser.list(
      response.data,
      keys: const ['categories'],
    ).map(CategoryModel.fromJson).toList();
  }

  Future<PreferencesModel> getPreferences() async {
    final response = await _client.get<dynamic>(ApiConstants.preferences);
    // Response may be null (no preferences set yet) — return empty model.
    if (response.data == null) return const PreferencesModel(categoryIds: []);
    final payload = ApiResponseParser.map(
      response.data,
      nestedKey: 'preferences',
    );
    return PreferencesModel.fromJson(payload);
  }

  /// SaveUserPreferencesDto: { userId, categoryids }
  ///
  /// The backend may return 204 (null body) on success.
  /// In that case we reconstruct the model from what we sent.
  Future<PreferencesModel> savePreferences(
    String userId,
    List<String> categoryIds,
  ) async {
    final response = await _client.post<dynamic>(
      ApiConstants.preferences,
      data: {'userId': userId, 'categoryids': categoryIds},
    );

    // 204 / null body — treat as success, return what we just saved.
    if (response.data == null) {
      return PreferencesModel(categoryIds: categoryIds);
    }

    // Try to parse the response body if one was returned.
    try {
      final payload = ApiResponseParser.map(
        response.data,
        nestedKey: 'preferences',
      );
      return PreferencesModel.fromJson(payload);
    } catch (_) {
      // Parsing failed — still treat as success with sent data.
      return PreferencesModel(categoryIds: categoryIds);
    }
  }
}
