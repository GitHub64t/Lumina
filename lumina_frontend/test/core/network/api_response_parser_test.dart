import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_frontend/core/errors/exceptions.dart';
import 'package:lumina_frontend/core/network/api_response_parser.dart';

void main() {
  group('ApiResponseParser', () {
    test('unwraps envelope maps before returning a payload map', () {
      final result = ApiResponseParser.map({
        'message': 'ok',
        'data': {
          'profile': {'id': 'user-1'},
        },
      }, nestedKey: 'profile');

      expect(result, {'id': 'user-1'});
    });

    test('extracts nested lists from common API list envelopes', () {
      final result = ApiResponseParser.list({
        'data': {
          'articles': [
            {'id': 'article-1'},
            {'id': 'article-2'},
          ],
        },
      });

      expect(result, [
        {'id': 'article-1'},
        {'id': 'article-2'},
      ]);
    });

    test('throws a server exception for invalid map responses', () {
      expect(
        () => ApiResponseParser.map(['not', 'a', 'map']),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
