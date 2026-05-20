class TokenModel {
  const TokenModel({required this.accessToken, this.refreshToken});

  final String accessToken;
  final String? refreshToken;

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    accessToken:
        json['accessToken']?.toString() ??
        json['access_token']?.toString() ??
        '',
    refreshToken:
        json['refreshToken']?.toString() ?? json['refresh_token']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}
