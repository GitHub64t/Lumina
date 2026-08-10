import 'package:form_validator/form_validator.dart';

class Validators {
  const Validators._();

  static String? email(String? value) =>
      ValidationBuilder().email().maxLength(80).build()(value);

  static String? password(String? value) => ValidationBuilder()
      .minLength(8, 'Use at least 8 characters')
      .regExp(RegExp(r'[A-Z]'), 'Include an uppercase letter')
      .regExp(RegExp(r'[0-9]'), 'Include a number')
      .build()(value);

  static String? requiredText(String? value) =>
      ValidationBuilder().required().maxLength(120).build()(value);

  /// Article body: 300–3000 characters.
  static String? articleContent(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Article content is required';
    if (trimmed.length < 300) {
      return 'Content must be at least 300 characters '
          '(${trimmed.length}/300)';
    }
    if (trimmed.length > 3000) {
      return 'Content must be at most 3000 characters '
          '(${trimmed.length}/3000)';
    }
    return null;
  }
}
