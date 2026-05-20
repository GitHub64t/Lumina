import '../../data/models/preferences_model.dart';
import '../repository/preferences_repository.dart';

class GetPreferencesUsecase {
  const GetPreferencesUsecase(this._repository);

  final PreferencesRepository _repository;

  Future<PreferencesModel> call() => _repository.getPreferences();
}
