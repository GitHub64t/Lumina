import '../../data/models/category_model.dart';
import '../repository/preferences_repository.dart';

class FetchCategoriesUsecase {
  const FetchCategoriesUsecase(this._repository);

  final PreferencesRepository _repository;

  Future<List<CategoryModel>> call() => _repository.fetchCategories();
}
