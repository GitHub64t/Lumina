import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/textfields/app_text_field.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../bloc/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Forgot Password — step 1: enter email to receive OTP
// ─────────────────────────────────────────────────────────────────────────────
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.passwordResetSent) {
          // Navigate to OTP + new-password page, carrying the email.
          context.go('/reset-password');
        }
        if (state.status == AuthStatus.failure && state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: _PasswordShell(
        title: 'Recover password',
        subtitle: 'Enter your email to receive a reset OTP.',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Email',
                controller: email,
                prefixIcon: Icons.mail_rounded,
                validator: Validators.email,
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => PrimaryButton(
                  label: 'Send OTP',
                  isLoading: state.status == AuthStatus.loading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                        AuthForgotPasswordRequested(email.text.trim()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reset Password — step 2: enter OTP + new password
// ResetPasswordDto: { email, otp, newPassword }
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  final _newPassword = TextEditingController();

  @override
  void dispose() {
    _otp.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.passwordResetSuccess) {
          context.go('/login');
        }
        if (state.status == AuthStatus.failure && state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final email = state.pendingResetEmail ?? '';
          return _PasswordShell(
            title: 'Set new password',
            subtitle: 'Enter the OTP sent to $email and choose a new password.',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'OTP code',
                    controller: _otp,
                    prefixIcon: Icons.pin_rounded,
                    keyboardType: TextInputType.number,
                    validator: Validators.requiredText,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'New password',
                    controller: _newPassword,
                    prefixIcon: Icons.lock_rounded,
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 8),
                  // Resend OTP option
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state.status == AuthStatus.loading
                          ? null
                          : () => context.read<AuthBloc>().add(
                                AuthForgotPasswordOtpResent(email),
                              ),
                      child: const Text('Resend OTP'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Update password',
                    isLoading: state.status == AuthStatus.loading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          AuthResetPasswordRequested(
                            email: email,
                            otp: _otp.text.trim(),
                            newPassword: _newPassword.text,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PasswordShell extends StatelessWidget {
  const _PasswordShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePage(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(subtitle),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
