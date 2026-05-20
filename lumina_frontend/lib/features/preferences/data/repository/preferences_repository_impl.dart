import '../../domain/repository/preferences_repository.dart';
import '../datasource/preferences_remote_datasource.dart';
import '../models/category_model.dart';
import '../models/preferences_model.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  const PreferencesRepositoryImpl({required PreferencesRemoteDatasource remote})
    : _remote = remote;

  final PreferencesRemoteDatasource _remote;

  @override
  Future<List<CategoryModel>> fetchCategories() => _remote.fetchCategories();

  @override
  Future<PreferencesModel> getPreferences() => _remote.getPreferences();

  @override
  Future<PreferencesModel> savePreferences(
    String userId,
    List<String> categoryIds,
  ) {
    return _remote.savePreferences(userId, categoryIds);
  }
}
