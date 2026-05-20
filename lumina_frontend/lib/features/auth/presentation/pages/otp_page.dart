import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  // 6 individual digit controllers for the split OTP input.
  final List<TextEditingController> _cells =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _cells) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  String get _otp => _cells.map((c) => c.text).join();

  void _onCellChanged(String value, int index) {
    if (value.length == 6) {
      // Handle paste of full OTP.
      for (int i = 0; i < 6; i++) {
        _cells[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
      return;
    }
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Widget _buildCell(int index) {
    return SizedBox(
      width: 48,
      child: TextFormField(
        controller: _cells[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: index == 0 ? 6 : 1, // first cell accepts paste
        onChanged: (v) => _onCellChanged(v, index),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) context.go('/dashboard');
          if (state.status == AuthStatus.otpResent) {
            _startTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP resent to your email')),
            );
          }
          if (state.status == AuthStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final email = state.user?.email ?? '';
            return ResponsivePage(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Icon ─────────────────────────────────────────────
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.mark_email_unread_rounded,
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Heading ───────────────────────────────────────────
                        Text(
                          'Verify your email',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'We sent a 6-digit code to '),
                              TextSpan(
                                text: email.isNotEmpty ? email : 'your email',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const TextSpan(
                                  text: '. Enter it below to continue.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── 6-cell OTP input ──────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, _buildCell),
                        ),
                        const SizedBox(height: 28),

                        // ── Verify button ─────────────────────────────────────
                        PrimaryButton(
                          label: 'Verify and continue',
                          icon: Icons.verified_rounded,
                          isLoading: state.status == AuthStatus.loading,
                          onPressed: () {
                            final code = _otp;
                            if (code.length == 6) {
                              context.read<AuthBloc>().add(
                                    AuthOtpVerified(code),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter the full 6-digit code'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── Resend row ────────────────────────────────────────
                        Center(
                          child: _seconds > 0
                              ? Text(
                                  'Resend code in ${_seconds}s',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                )
                              : TextButton.icon(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                          const AuthOtpResent(),
                                        );
                                  },
                                  icon: const Icon(Icons.refresh_rounded,
                                      size: 18),
                                  label: const Text('Resend OTP'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
