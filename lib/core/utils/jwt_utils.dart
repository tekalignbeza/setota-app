import 'dart:convert';

class JwtUtils {
  JwtUtils._();

  /// Decodes a JWT token and returns the payload as a Map.
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Extracts the expiration timestamp (in seconds) from a JWT token.
  static int? extractExpiration(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;
    return payload['exp'] as int?;
  }

  /// Returns true if the JWT token is expired.
  static bool isExpired(String token, {int bufferSeconds = 60}) {
    final exp = extractExpiration(token);
    if (exp == null) return true;

    final expirationDate =
        DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    final now = DateTime.now().toUtc();
    return now.isAfter(expirationDate.subtract(Duration(seconds: bufferSeconds)));
  }

  /// Extracts the user ID (sub claim) from a JWT token.
  static String? extractUserId(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;
    return payload['sub'] as String? ?? payload['userId'] as String?;
  }

  /// Extracts the customer ID from a JWT token.
  static String? extractCustomerId(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;
    return payload['customerId'] as String?;
  }

  /// Extracts the roles from a JWT token.
  static List<String> extractRoles(String token) {
    final payload = decodePayload(token);
    if (payload == null) return [];
    final roles = payload['roles'];
    if (roles is List) return roles.cast<String>();
    return [];
  }
}
