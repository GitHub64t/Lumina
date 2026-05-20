// LoginDto: credential (email OR phone), password
class LoginModel {
  const LoginModel({required this.credential, required this.password});

  final String credential; // email or phone number
  final String password;

  Map<String, dynamic> toJson() => {
    'credential': credential,
    'password': password,
  };
}
