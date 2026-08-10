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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Resolve ID: check every common key name used by REST APIs and JWT payloads.
    final id = json['id']?.toString() ??
        json['_id']?.toString() ??
        json['userId']?.toString() ??
        json['user_id']?.toString() ??
        json['sub']?.toString() ??
        json['uuid']?.toString() ??
        '';

    assert(() {
      if (id.isEmpty) {
        // ignore: avoid_print
        print('[UserModel] ⚠️  id is empty! JSON keys: ${json.keys.toList()}');
      } else {
        // ignore: avoid_print
        print('[UserModel] ✅ id resolved to: $id');
      }
      return true;
    }());

    return UserModel(
      id: id,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ??
          json['profileImage']?.toString(),
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
}
