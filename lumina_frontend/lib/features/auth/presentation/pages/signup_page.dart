import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/chips/category_chip.dart';
import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/widgets/loaders/skeleton_loader.dart';
import '../../../../core/widgets/textfields/app_text_field.dart';
import '../../../../injection_container.dart';
import '../../../preferences/presentation/bloc/preferences_cubit.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../bloc/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Signup flow (3 steps):
//
//   Step 0 ──▶ Email only
//   Step 1 ──▶ Personal details (firstName, lastName, phone, dob, password)
//   Step 2 ──▶ Category preferences
//              └─ Submit ALL to POST /auth/signup
//                 └─ Navigate to /otp  (verify + resend handled there)
// ─────────────────────────────────────────────────────────────────────────────

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // ── Form keys ──────────────────────────────────────────────────────────────
  final _emailFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────────────────
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController(); // stable – never recreated
  final _password = TextEditingController();

  DateTime? _dateOfBirth;
  int _step = 0; // 0 → email, 1 → details, 2 → categories

  @override
  void dispose() {
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _dob.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13),
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dob.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // ── Step titles ───────────────────────────────────────────────────────────
  String get _title => switch (_step) {
    0 => 'Create account',
    1 => 'Your details',
    _ => 'Choose topics',
  };

  String get _subtitle => switch (_step) {
    0 => 'Enter your email address to get started.',
    1 => 'Tell us a bit more about yourself.',
    _ => 'Select topics that shape your personalized feed.',
  };

  // ── Step indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final active = i == _step;
        final done = i < _step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: done || active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: .35),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreferencesCubit(sl.preferencesRepository)..load(),
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) async {
                if (state.status == AuthStatus.pendingOtp) {
                  // Save category preferences before navigating.
                  final preferencesCubit = context.read<PreferencesCubit>();
                  final router = GoRouter.of(context);
                  if (state.user != null) {
                    await preferencesCubit.save(state.user!.id);
                  }
                  if (!mounted) return;
                  router.go('/otp');
                  return;
                }
                if (state.status == AuthStatus.failure &&
                    state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!)),
                  );
                }
              },
            ),
            BlocListener<PreferencesCubit, PreferencesState>(
              listener: (context, state) {
                if (state.status == PreferencesStatus.failure &&
                    state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!)),
                  );
                }
              },
            ),
          ],
          child: ResponsivePage(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // ── Progress indicator ─────────────────────────────────
                    _buildStepIndicator(),
                    const SizedBox(height: 28),

                    // ── Title ─────────────────────────────────────────────
                    Text(
                      _title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .65),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Step 0: Email ──────────────────────────────────────
                    if (_step == 0) ...[
                      Form(
                        key: _emailFormKey,
                        child: AppTextField(
                          label: 'Email address',
                          controller: _email,
                          prefixIcon: Icons.mail_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_emailFormKey.currentState!.validate()) {
                            setState(() => _step = 1);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Already have an account? Log in'),
                        ),
                      ),
                    ]

                    // ── Step 1: Personal details ───────────────────────────
                    else if (_step == 1) ...[
                      Form(
                        key: _detailsFormKey,
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
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Phone number',
                              controller: _phone,
                              prefixIcon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              validator: Validators.requiredText,
                            ),
                            const SizedBox(height: 16),
                            // DOB — stable controller, readOnly prevents IME
                            TextFormField(
                              controller: _dob,
                              readOnly: true,
                              onTap: _pickDate,
                              validator: (_) => _dateOfBirth == null
                                  ? 'Please select your date of birth'
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Date of birth',
                                prefixIcon: Icon(Icons.calendar_month_rounded),
                                hintText: 'YYYY-MM-DD',
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Password',
                              controller: _password,
                              prefixIcon: Icons.lock_rounded,
                              obscureText: true,
                              validator: Validators.password,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_detailsFormKey.currentState!.validate()) {
                            setState(() => _step = 2);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _step = 0),
                          child: const Text('Back'),
                        ),
                      ),
                    ]

                    // ── Step 2: Category preferences ───────────────────────
                    else ...[
                      BlocBuilder<PreferencesCubit, PreferencesState>(
                        builder: (context, state) {
                          if (state.status == PreferencesStatus.loading) {
                            return const SkeletonLoader(shrinkWrap: true);
                          }
                          if (state.status == PreferencesStatus.failure) {
                            return AppErrorState(
                              message:
                                  state.error ?? 'Unable to load categories',
                              onRetry: () =>
                                  context.read<PreferencesCubit>().load(),
                            );
                          }
                          if (state.categories.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final cat in state.categories)
                                CategoryChip(
                                  label: cat.name,
                                  selected: state.selectedIds.contains(cat.id),
                                  onSelected: (_) => context
                                      .read<PreferencesCubit>()
                                      .toggle(cat.id),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Create account button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => PrimaryButton(
                          label: 'Create account',
                          icon: Icons.check_rounded,
                          isLoading: state.status == AuthStatus.loading,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              AuthSignupRequested(
                                firstName: _firstName.text.trim(),
                                lastName: _lastName.text.trim(),
                                email: _email.text.trim(),
                                phone: _phone.text.trim(),
                                dateOfBirth: _dob.text,
                                password: _password.text,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _step = 1),
                          child: const Text('Back'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
