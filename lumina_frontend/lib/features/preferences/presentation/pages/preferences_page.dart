import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/chips/category_chip.dart';
import '../../../../core/widgets/empty_states/app_empty_state.dart';
import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/widgets/loaders/skeleton_loader.dart';
import '../../../../core/utils/session_error_handler.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/preferences_cubit.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreferencesCubit(sl.preferencesRepository)..load(),
      child: Scaffold(
        body: BlocConsumer<PreferencesCubit, PreferencesState>(
          listener: (context, state) {
            if (state.status == PreferencesStatus.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferences saved')),
              );
            }
            if (state.status == PreferencesStatus.failure &&
                state.error != null) {
              SessionErrorHandler.handle(context, state.error);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            if (state.status == PreferencesStatus.loading) {
              return const ResponsivePage(child: SkeletonLoader());
            }
            if (state.status == PreferencesStatus.failure &&
                state.categories.isEmpty) {
              return ResponsivePage(
                child: AppErrorState(
                  message: state.error ?? 'Unable to load preferences',
                  onRetry: () => context.read<PreferencesCubit>().load(),
                ),
              );
            }
            if (state.categories.isEmpty) {
              return const ResponsivePage(
                child: AppEmptyState(
                  title: 'No categories available',
                  message:
                      'Categories will appear here when the API returns them.',
                ),
              );
            }

            return ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select topics that shape your personalized feed.',
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final category in state.categories)
                        CategoryChip(
                          label: category.name,
                          selected: state.selectedIds.contains(category.id),
                          onSelected: (_) => context
                              .read<PreferencesCubit>()
                              .toggle(category.id),
                        ),
                    ],
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Save preferences',
                    isLoading: state.status == PreferencesStatus.saving,
                    onPressed: state.selectedIds.isEmpty
                        ? null
                        : () {
                            final userId =
                                context.read<AuthBloc>().state.user?.id ?? '';
                            context.read<PreferencesCubit>().save(userId);
                          },
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
