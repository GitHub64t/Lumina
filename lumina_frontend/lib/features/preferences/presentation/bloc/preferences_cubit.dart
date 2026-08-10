import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/category_model.dart';
import '../../domain/repository/preferences_repository.dart';

enum PreferencesStatus { initial, loading, success, saving, saved, failure }

class PreferencesState extends Equatable {
  const PreferencesState({
    this.status = PreferencesStatus.initial,
    this.categories = const [],
    this.selectedIds = const {},
    this.error,
  });

  final PreferencesStatus status;
  final List<CategoryModel> categories;
  final Set<String> selectedIds;
  final String? error;

  bool get isBusy =>
      status == PreferencesStatus.loading || status == PreferencesStatus.saving;

  PreferencesState copyWith({
    PreferencesStatus? status,
    List<CategoryModel>? categories,
    Set<String>? selectedIds,
    String? error,
    bool clearError = false,
  }) {
    return PreferencesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedIds: selectedIds ?? this.selectedIds,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, categories, selectedIds, error];
}

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit(this._repository) : super(const PreferencesState());

  final PreferencesRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: PreferencesStatus.loading, clearError: true));
    try {
      final categories = await _repository.fetchCategories();
      final selectedIds = await _loadSelectedIds();
      emit(
        state.copyWith(
          status: PreferencesStatus.success,
          categories: categories,
          selectedIds: selectedIds,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PreferencesStatus.failure,
          error: error.toString(),
        ),
      );
    }
  }

  Future<Set<String>> _loadSelectedIds() async {
    try {
      final preferences = await _repository.getPreferences();
      return preferences.categoryIds.toSet();
    } catch (_) {
      return const {};
    }
  }

  void toggle(String id) {
    final selected = {...state.selectedIds};
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    emit(state.copyWith(selectedIds: selected));
  }

  /// [userId] is required by SaveUserPreferencesDto.
  Future<void> save(String userId) async {
    if (userId.isEmpty) {
      emit(
        state.copyWith(
          status: PreferencesStatus.failure,
          error: 'User session is missing. Please log in again.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: PreferencesStatus.saving, clearError: true));
    try {
      final preferences = await _repository.savePreferences(
        userId,
        state.selectedIds.toList(),
      );
      emit(
        state.copyWith(
          status: PreferencesStatus.saved,
          selectedIds: preferences.categoryIds.toSet(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PreferencesStatus.failure,
          error: error.toString(),
        ),
      );
    }
  }
}
