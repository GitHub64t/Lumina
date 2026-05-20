// Signup: firstName, lastName, email, phone, dateOfBirth, password
class SignupModel {
  const SignupModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth; // ISO date string e.g. "1998-05-20"
  final String password;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'dateOfBirth': dateOfBirth,
    'password': password,
  };
}
