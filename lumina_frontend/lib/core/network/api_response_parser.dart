import '../errors/exceptions.dart';

class ApiResponseParser {
  const ApiResponseParser._();

  static Map<String, dynamic> map(
    Object? data, {
    String? nestedKey,
    String fallbackMessage = 'Invalid API response',
  }) {
    final payload = unwrap(data);
    final value = nestedKey == null ? payload : _readNested(payload, nestedKey);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw ServerException(fallbackMessage);
  }

  static List<Map<String, dynamic>> list(
    Object? data, {
    List<String> keys = const ['items', 'results', 'articles', 'categories'],
  }) {
    final payload = unwrap(data);
    final value = _firstList(payload, keys) ?? payload;
    if (value == null) return const [];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    throw const ServerException('Invalid list response from server');
  }

  static Object? unwrap(Object? data) {
    Object? current = data;
    for (var i = 0; i < 4; i++) {
      if (current is Map) {
        if (current['data'] is Map || current['data'] is List) {
          current = current['data'];
          continue;
        }
        if (current['result'] is Map || current['result'] is List) {
          current = current['result'];
          continue;
        }
        if (current['payload'] is Map || current['payload'] is List) {
          current = current['payload'];
          continue;
        }
      }
      return current;
    }
    return current;
  }

  static Object? _readNested(Object? payload, String key) {
    if (payload is Map && payload[key] != null) return payload[key];
    return payload;
  }

  static Object? _firstList(Object? payload, List<String> keys) {
    if (payload is List) return payload;
    if (payload is! Map) return null;
    for (final key in keys) {
      final value = payload[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _firstList(value, keys);
        if (nested != null) return nested;
      }
    }
    return null;
  }
}
