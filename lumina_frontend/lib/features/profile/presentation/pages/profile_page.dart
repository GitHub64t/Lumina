import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/widgets/loaders/skeleton_loader.dart';
import '../../../../core/widgets/textfields/app_text_field.dart';
import '../../../../core/utils/session_error_handler.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/profile_model.dart';
import '../bloc/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  String _getAvatarInitial(ProfileModel? profile) {
    if (profile != null) {
      final first = profile.firstName.trim();
      if (first.isNotEmpty) {
        return first.characters.first.toUpperCase();
      }
      final email = profile.email.trim();
      if (email.isNotEmpty) {
        return email.characters.first.toUpperCase();
      }
    }
    return 'A';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
          centerTitle: false,
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            final profile = state.profile;
            if (!_prefilled && profile != null) {
              _firstName.text = profile.firstName;
              _lastName.text = profile.lastName;
              _prefilled = true;
            }
            if (state.status == ProfileStatus.updated) {
              if (profile != null) {
                _firstName.text = profile.firstName;
                _lastName.text = profile.lastName;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
            }
            if (state.status == ProfileStatus.passwordChanged) {
              _oldPassword.clear();
              _newPassword.clear();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
            }
            if (state.status == ProfileStatus.failure && state.error != null) {
              SessionErrorHandler.handle(context, state.error);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const ResponsivePage(child: SkeletonLoader());
            }
            if (state.status == ProfileStatus.failure &&
                state.profile == null) {
              return ResponsivePage(
                child: AppErrorState(
                  message: state.error ?? 'Unable to load profile',
                  onRetry: () => context.read<ProfileCubit>().load(),
                ),
              );
            }

            final profile = state.profile;
            final userId =
                context.read<AuthBloc>().state.user?.id ?? profile?.id ?? '';

            return ResponsivePage(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundImage: profile?.avatarUrl == null
                            ? null
                            : NetworkImage(profile!.avatarUrl!),
                        child: profile?.avatarUrl == null
                            ? Text(
                                _getAvatarInitial(profile),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? 'Profile',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (profile?.email != null && profile!.email.isNotEmpty)
                              Text(profile.email),
                            if (profile?.phone != null && profile!.phone.isNotEmpty)
                              Text(
                                profile.phone,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Personal details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // ── Update profile form ───────────────────────────────────
                  Form(
                    key: _profileFormKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'First name',
                                controller: _firstName,
                                prefixIcon: Icons.person_rounded,
                                validator: Validators.requiredText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Last name',
                                controller: _lastName,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: Validators.requiredText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Save profile',
                          isLoading: state.status == ProfileStatus.updating,
                          onPressed: () {
                            if (!_profileFormKey.currentState!.validate()) {
                              return;
                            }
                            context.read<ProfileCubit>().update(
                              userId: userId,
                              firstName: _firstName.text.trim(),
                              lastName: _lastName.text.trim(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Change password',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // ── Change password form ──────────────────────────────────
                  Form(
                    key: _passwordFormKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Current password',
                          controller: _oldPassword,
                          prefixIcon: Icons.lock_rounded,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'New password',
                          controller: _newPassword,
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Change password',
                          isLoading:
                              state.status == ProfileStatus.changingPassword,
                          onPressed: () {
                            if (!_passwordFormKey.currentState!.validate()) {
                              return;
                            }
                            context.read<ProfileCubit>().changePassword(
                              userId: userId,
                              oldPassword: _oldPassword.text,
                              newPassword: _newPassword.text,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
