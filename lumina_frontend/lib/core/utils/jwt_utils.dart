import 'dart:convert';

/// Decodes a JWT access token and returns the payload as a Map.
/// Returns null if the token is missing or malformed.
Map<String, dynamic>? decodeJwtPayload(String? token) {
  if (token == null || token.isEmpty) return null;
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    // Base64url decode the payload (index 1).
    String payload = parts[1];
    // Pad to a multiple of 4 for standard base64.
    final padding = 4 - payload.length % 4;
    if (padding != 4) payload += '=' * padding;
    final decoded = utf8.decode(base64Url.decode(payload));
    return Map<String, dynamic>.from(jsonDecode(decoded) as Map);
  } catch (_) {
    return null;
  }
}

/// Extracts the user ID from a JWT token.
/// Checks `sub`, `id`, `userId`, `_id` in the payload.
String? userIdFromJwt(String? token) {
  final payload = decodeJwtPayload(token);
  if (payload == null) return null;
  return payload['sub']?.toString() ??
      payload['id']?.toString() ??
      payload['userId']?.toString() ??
      payload['_id']?.toString();
}
