import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? dateOfBirth;
  final String? avatarUrl;

  /// Convenience getter for displaying full name.
  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phone, dateOfBirth, avatarUrl];
}
