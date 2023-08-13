import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:the_api/api.dart';

void main() {
  group('oauth/token', () {
    late Api api;
    const apiRoot = 'https://xfrocks.com/api/index.php';
    const clientId = 'gljf4391k3';
    const clientSecret = 'zw3lj0zox6be4z2';
    const username = 'api-tester';
    const email = 'api-tester@xfrocks.com';
    const password = '@pi-T3st3r';
    const userId = 2394;
    setUp(() {
      api = Api(
        http.Client(),
        apiRoot: apiRoot,
        clientId: clientId,
        clientSecret: clientSecret,
      );
    });
    tearDown(() => api.close());

    group('grant_type=password', () {
      test('works with username/password', () async {
        final result = await login(api, username, password);
        final resultUserId =
            result.maybeMap(token: (x) => x.token.userId, orElse: () => 0);
        expect(resultUserId, equals(userId));
      });

      test('works with email/password', () async {
        final result = await login(api, email, password);
        final resultUserId =
            result.maybeMap(token: (x) => x.token.userId, orElse: () => 0);
        expect(resultUserId, equals(userId));
      });

      test('fails with wrong password', () {
        expect(login(api, username, 'xxx'),
            throwsA(const TypeMatcher<ApiError>()));
      });
    });

    group('grant_type=refresh_token', () {
      test('works', () async {
        final loginResult = await login(api, username, password);
        final token =
            loginResult.maybeMap(token: (x) => x.token, orElse: () => null);
        final refreshedToken = await api.refreshToken(token!);
        expect(refreshedToken?.userId, equals(userId));
      });
    });
  });
}
