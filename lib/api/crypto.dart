import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

String md5(String input) {
  final bytes = Utf8Encoder().convert(input);
  final digest = crypto.md5.convert(bytes);
  return hex.encode(digest.bytes);
}