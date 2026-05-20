import '../../data/models/preferences_model.dart';
import '../repository/preferences_repository.dart';

class SavePreferencesUsecase {
  const SavePreferencesUsecase(this._repository);

  final PreferencesRepository _repository;

  /// [userId] is required by SaveUserPreferencesDto.
  Future<PreferencesModel> call(String userId, List<String> categoryIds) =>
      _repository.savePreferences(userId, categoryIds);
}
