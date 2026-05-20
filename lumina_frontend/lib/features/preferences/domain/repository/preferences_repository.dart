import '../../data/models/category_model.dart';
import '../../data/models/preferences_model.dart';

abstract class PreferencesRepository {
  Future<List<CategoryModel>> fetchCategories();
  Future<PreferencesModel> getPreferences();
  /// SaveUserPreferencesDto requires userId alongside categoryIds.
  Future<PreferencesModel> savePreferences(
    String userId,
    List<String> categoryIds,
  );
}
