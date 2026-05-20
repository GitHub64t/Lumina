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
}
