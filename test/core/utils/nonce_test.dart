import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/core/utils/nonce.dart';

void main() {
  group('generateRawNonce', () {
    test('defaults to a 32 character string', () {
      expect(generateRawNonce(), hasLength(32));
    });

    test('respects a custom length', () {
      expect(generateRawNonce(10), hasLength(10));
    });

    test('generates different values on each call', () {
      expect(generateRawNonce(), isNot(generateRawNonce()));
    });
  });

  group('sha256OfString', () {
    test('matches a known SHA-256 digest', () {
      expect(
        sha256OfString(''),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('is deterministic for the same input', () {
      expect(sha256OfString('hello'), sha256OfString('hello'));
    });

    test('differs for different inputs', () {
      expect(sha256OfString('hello'), isNot(sha256OfString('world')));
    });
  });
}
