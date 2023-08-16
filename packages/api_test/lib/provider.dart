import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:the_api_test/src/mocked_http_client.dart';

class MockedHttpClientProvider extends StatelessWidget {
  final Widget child;

  const MockedHttpClientProvider({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<http.Client>(
      create: (_) => mockedHttpClient,
      child: child,
    );
  }
}
