import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

class SessionErrorHandler {
  const SessionErrorHandler._();

  static void handle(BuildContext context, String? message) {
    final value = message?.toLowerCase() ?? '';
    if (value.contains('session expired') || value.contains('unauthorized')) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }
}
