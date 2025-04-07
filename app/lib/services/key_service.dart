import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';

class KeyService {
  // --- Singleton Setup ---
  KeyService._privateConstructor();
  static final KeyService instance = KeyService._privateConstructor();
  // --- ---

  final _secureStorage = const FlutterSecureStorage();
  final _algorithm = Ed25519();

  static const _privateKeyStoreKey = 'userPrivateKey_ed25519';
  static const _publicKeyStoreKey = 'userPublicKey_ed25519';

  String? _publicKeyString;

  String get publicKey {
    if (_publicKeyString == null) {
      throw StateError('KeyService not initialized or key generation failed.');
    }
    return _publicKeyString!;
  }

  Future<void> generateKeys() async {
    final newKeyPair = await _algorithm.newKeyPair();
    final publicKey = await newKeyPair.extractPublicKey();
    // Extract the private key seed bytes for storage
    final privateKeyBytes = await newKeyPair.extractPrivateKeyBytes();
    final publicKeyBytes = publicKey.bytes;

    final privateKeyString = base64Encode(privateKeyBytes);
    final publicKeyString = base64Encode(publicKeyBytes);

    await _secureStorage.write(
        key: _privateKeyStoreKey, value: privateKeyString);
    await _secureStorage.write(key: _publicKeyStoreKey, value: publicKeyString);

    _publicKeyString = publicKeyString;
    debugPrint('KeyService: New keys generated and stored.');
  }

  Future<void> initialize() async {
    final storedPrivateKey =
        await _secureStorage.read(key: _privateKeyStoreKey);
    final storedPublicKey = await _secureStorage.read(key: _publicKeyStoreKey);

    if (storedPrivateKey != null && storedPublicKey != null) {
      debugPrint('KeyService: Existing keys found.');
      _publicKeyString = storedPublicKey;
    } else {
      debugPrint('KeyService: No keys found. Generating new ones...');
      await generateKeys();
    }
  }

  Future<Uint8List?> getPrivateKeyBytes() async {
    final privateKeyString =
        await _secureStorage.read(key: _privateKeyStoreKey);
    if (privateKeyString != null) {
      try {
        return base64Decode(privateKeyString);
      } catch (e) {
        debugPrint('KeyService: Error decoding private key: $e');
        return null;
      }
    }
    debugPrint('KeyService: Private key not found in storage.');
    return null;
  }

  /// Signs the provided Base64 encoded nonce using the stored private key.
  ///
  /// Returns the Base64 encoded signature, or null if the private key
  /// cannot be retrieved or signing fails.
  Future<String?> signNonce(String nonceB64) async {
    // Retrieve the private key bytes securely
    final privateKeyBytes = await getPrivateKeyBytes();
    if (privateKeyBytes == null) {
      debugPrint('KeyService: Cannot sign nonce, private key not available.');
      return null;
    }

    try {
      // Decode the nonce from Base64
      final nonceBytes = base64Decode(nonceB64);

      // Reconstruct the key pair data from the stored private key bytes
      // For Ed25519, the private key bytes obtained from extractPrivateKeyBytes()
      // are typically the seed, which the algorithm uses to derive the full key pair.
      final keyPair = await _algorithm.newKeyPairFromSeed(privateKeyBytes);

      // Sign the nonce bytes using the reconstructed key pair
      final signature = await _algorithm.sign(
        nonceBytes, // Data to sign (must be List<int> or Uint8List)
        keyPair: keyPair, // The key pair to sign with
      );

      // 5. Encode the resulting signature bytes to Base64
      final signatureB64 = base64Encode(signature.bytes);

      return signatureB64;
    } catch (e) {
      debugPrint('KeyService: Error signing nonce: $e');
      return null; // Return null if any error occurs during decoding/signing
    }
  }

  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _privateKeyStoreKey);
    await _secureStorage.delete(key: _publicKeyStoreKey);
    _publicKeyString = null;
    debugPrint('KeyService: Keys cleared.');
  }
}
