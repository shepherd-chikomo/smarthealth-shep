import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// PIN-derived portable backup encryption (v2 envelope).
class HealthVaultBackupCrypto {
  HealthVaultBackupCrypto({
    Pbkdf2? pbkdf2,
    AesGcm? aes,
  })  : _pbkdf2 = pbkdf2 ??
            Pbkdf2(
              macAlgorithm: Hmac.sha256(),
              iterations: 120000,
              bits: 256,
            ),
        _aes = aes ?? AesGcm.with256bits();

  static const envelopeVersion = 2;
  static const wrongPinMessage = 'Incorrect PIN or corrupted backup file.';

  final Pbkdf2 _pbkdf2;
  final AesGcm _aes;

  Future<String> encryptJson(Map<String, dynamic> json, String pin) async {
    final salt = _randomBytes(16);
    final key = await _deriveKey(pin, salt);
    final nonce = _aes.newNonce();
    final secretBox = await _aes.encrypt(
      utf8.encode(jsonEncode(json)),
      secretKey: key,
      nonce: nonce,
    );
    return jsonEncode({
      'v': envelopeVersion,
      'format': 'healthvault',
      'kdf': 'pbkdf2-sha256',
      'iterations': 120000,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'cipher': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });
  }

  Future<Map<String, dynamic>> decryptJson(String envelope, String pin) async {
    final parsed = jsonDecode(envelope) as Map<String, dynamic>;
    final version = parsed['v'] as int? ?? 1;
    if (version != envelopeVersion) {
      throw FormatException(wrongPinMessage);
    }

    final salt = base64Decode(parsed['salt'] as String);
    final nonce = base64Decode(parsed['nonce'] as String);
    final cipherText = base64Decode(parsed['cipher'] as String);
    final mac = Mac(base64Decode(parsed['mac'] as String));
    final key = await _deriveKey(pin, salt);

    try {
      final clear = await _aes.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: key,
      );
      return jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
    } on SecretBoxAuthenticationError {
      throw FormatException(wrongPinMessage);
    }
  }

  Future<SecretKey> _deriveKey(String pin, List<int> salt) {
    return _pbkdf2.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
