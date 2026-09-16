import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates a cryptographically secure random nonce, matching Supabase's
/// documented Apple Sign-In recipe for Flutter.
String generateRawNonce([int length = 32]) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

String sha256OfString(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}
