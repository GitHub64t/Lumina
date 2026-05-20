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

  String get fullName => '$firstName $lastName'.trim();

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    dateOfBirth: json['dateOfBirth']?.toString(),
    avatarUrl: json['avatarUrl']?.toString() ?? json['profileImage']?.toString(),
  );

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
