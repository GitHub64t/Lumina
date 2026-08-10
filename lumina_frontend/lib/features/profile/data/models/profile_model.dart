import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  const ProfileModel({
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

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Profile' : name;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final map = (json['user'] is Map)
        ? Map<String, dynamic>.from(json['user'] as Map)
        : (json['profile'] is Map)
            ? Map<String, dynamic>.from(json['profile'] as Map)
            : json;

    final first = map['firstName'] ?? map['first_name'] ?? map['name'] ?? '';
    final last = map['lastName'] ?? map['last_name'] ?? '';
    final email = map['email'] ?? '';
    final phone = map['phone'] ?? map['phoneNumber'] ?? '';

    return ProfileModel(
      id: (map['id'] ?? map['_id'])?.toString() ?? '',
      firstName: first.toString(),
      lastName: last.toString(),
      email: email.toString(),
      phone: phone.toString(),
      dateOfBirth: map['dateOfBirth']?.toString() ?? map['dob']?.toString(),
      avatarUrl: map['avatarUrl']?.toString() ??
          map['profileImage']?.toString() ??
          map['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'dateOfBirth': dateOfBirth,
    'avatarUrl': avatarUrl,
  };

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phone, dateOfBirth, avatarUrl];
}
