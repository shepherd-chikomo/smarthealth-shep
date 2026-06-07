import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256-GCM encryption for Health Vault payloads at rest.
class HealthVaultCrypto {
  HealthVaultCrypto({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _keyStorageKey = 'sh_health_vault_dek_v1';
  final FlutterSecureStorage _storage;
  final _algorithm = AesGcm.with256bits();

  Future<SecretKey> _loadOrCreateKey() async {
    final existing = await _storage.read(key: _keyStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return SecretKey(base64Decode(existing));
    }
    final key = await _algorithm.newSecretKey();
    final bytes = await key.extractBytes();
    await _storage.write(key: _keyStorageKey, value: base64Encode(bytes));
    return key;
  }

  Future<String> encryptJson(Map<String, dynamic> json) async {
    final key = await _loadOrCreateKey();
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      utf8.encode(jsonEncode(json)),
      secretKey: key,
      nonce: nonce,
    );
    return jsonEncode({
      'v': 1,
      'nonce': base64Encode(nonce),
      'cipher': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });
  }

  Future<Map<String, dynamic>> decryptJson(String envelope) async {
    final key = await _loadOrCreateKey();
    final parsed = jsonDecode(envelope) as Map<String, dynamic>;
    final nonce = base64Decode(parsed['nonce'] as String);
    final cipherText = base64Decode(parsed['cipher'] as String);
    final mac = Mac(base64Decode(parsed['mac'] as String));
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final clear = await _algorithm.decrypt(secretBox, secretKey: key);
    return jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
  }

  Future<void> wipeKey() => _storage.delete(key: _keyStorageKey);
}
