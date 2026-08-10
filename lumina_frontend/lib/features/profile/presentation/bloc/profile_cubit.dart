import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/profile_model.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  updating,
  updated,
  changingPassword,
  passwordChanged,
  failure,
}

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.error,
  });

  final ProfileStatus status;
  final ProfileModel? profile;
  final String? error;

  bool get isBusy =>
      status == ProfileStatus.loading ||
      status == ProfileStatus.updating ||
      status == ProfileStatus.changingPassword;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, profile, error];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfileUsecase getProfileUsecase,
    required UpdateProfileUsecase updateProfileUsecase,
    required ChangePasswordUsecase changePasswordUsecase,
  }) : _getProfileUsecase = getProfileUsecase,
       _updateProfileUsecase = updateProfileUsecase,
       _changePasswordUsecase = changePasswordUsecase,
       super(const ProfileState());

  final GetProfileUsecase _getProfileUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final ChangePasswordUsecase _changePasswordUsecase;

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    try {
      final profile = await _getProfileUsecase();
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (error) {
      emit(
        state.copyWith(status: ProfileStatus.failure, error: error.toString()),
      );
    }
  }

  Future<void> update({
    required String userId,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
  }) async {
    final effectiveUserId = userId.isNotEmpty ? userId : (state.profile?.id ?? '');
    emit(state.copyWith(status: ProfileStatus.updating, clearError: true));
    try {
      final profile = await _updateProfileUsecase(
        userId: effectiveUserId,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
      );
      emit(state.copyWith(status: ProfileStatus.updated, profile: profile));
    } catch (error) {
      emit(
        state.copyWith(status: ProfileStatus.failure, error: error.toString()),
      );
    }
  }

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final effectiveUserId = userId.isNotEmpty ? userId : (state.profile?.id ?? '');
    emit(
      state.copyWith(status: ProfileStatus.changingPassword, clearError: true),
    );
    try {
      await _changePasswordUsecase(
        userId: effectiveUserId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      emit(state.copyWith(status: ProfileStatus.passwordChanged));
    } catch (error) {
      emit(
        state.copyWith(status: ProfileStatus.failure, error: error.toString()),
      );
    }
  }
}
