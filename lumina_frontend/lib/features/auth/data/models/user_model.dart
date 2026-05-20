import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    super.dateOfBirth,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
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
}
