import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:cryptography/cryptography.dart';
import 'package:pinenacl/tweetnacl.dart';

import 'package:whisper/services/key_service.dart';

class EncryptionService {
  final KeyService _keyService = KeyService.instance;
  final _x25519 = X25519();
  final _aeadAlgorithm = Chacha20.poly1305Aead();

  // Constants for cryptographic sizes
  static const int _x25519PublicKeySize = 32;
  static const int _chachaNonceSize = 12; // Standard for ChaCha20Poly1305
  static const int _poly1305MacSize = 16; // Standard for ChaCha20Poly1305

  // Helper to get our own X25519 key pair derived from the stored Ed25519 key
  Future<KeyPair?> _getMyX25519KeyPair() async {
    final privateKeyBytes = await _keyService.getPrivateKeyBytes();
    if (privateKeyBytes == null) {
      debugPrint('EncryptionService: Failed to get private key bytes.');
      return null;
    }
    try {
      // Convert to X25519 key pair for key exchange
      Uint8List x25519PrivateKey = Uint8List.fromList(List.filled(32, 0));
      TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(
          x25519PrivateKey, privateKeyBytes);

      final x25519KeyPair = await _x25519.newKeyPairFromSeed(x25519PrivateKey);

      return x25519KeyPair;
    } catch (e) {
      debugPrint('EncryptionService: Error deriving X25519 key pair: $e');
      return null;
    }
  }

  // Helper to get an X25519 public key from a Base64 encoded Ed25519 public key
  Future<SimplePublicKey?> _getX25519PublicKeyFromEd25519String(
      String ed25519PublicKeyString) async {
    try {
      final publicKeyBytes = base64Decode(ed25519PublicKeyString);
      // Convert Ed25519 public key to X25519 public key
      final x25519PublicKeyBytes = Uint8List.fromList(List.filled(32, 0));
      TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(
          x25519PublicKeyBytes, publicKeyBytes);

      // Convert to SimplePublicKey for use with X25519
      final x25519PublicKey = SimplePublicKey(
        x25519PublicKeyBytes,
        type: KeyPairType.x25519,
      );

      return x25519PublicKey;
    } catch (e) {
      debugPrint('EncryptionService: Error deriving X25519 public key: $e');
      return null;
    }
  }

  /// Encrypts data for a recipient using their Ed25519 public key.
  ///
  /// Returns Base64 encoded string containing:
  /// EphemeralPublicKeyBytes(32) + Nonce(12) + Ciphertext + MAC(16)
  /// Returns null on failure.
  Future<String?> encrypt(
      String data, String recipientEd25519PublicKeyString) async {
    try {
      final recipientPublicKey = await _getX25519PublicKeyFromEd25519String(
          recipientEd25519PublicKeyString);
      if (recipientPublicKey == null) {
        debugPrint('EncryptionService: Invalid recipient public key.');
        return null;
      }

      // 1. Generate an ephemeral X25519 key pair for this encryption
      final ephemeralKeyPair = await _x25519.newKeyPair();
      final ephemeralPublicKey = await ephemeralKeyPair.extractPublicKey();
      final ephemeralPublicKeyBytes = ephemeralPublicKey.bytes;

      // 2. Perform key agreement: ephemeral private key <-> recipient public key
      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: ephemeralKeyPair,
        remotePublicKey: recipientPublicKey,
      );

      // 3. Encrypt the data using the shared secret
      final dataBytes = utf8.encode(data);
      final secretBox = await _aeadAlgorithm.encrypt(
        dataBytes,
        secretKey: sharedSecret,
      );

      // 4. Prepend the ephemeral public key bytes to the SecretBox bytes
      // SecretBox.concatenation() gives: nonce + ciphertext + mac
      Uint8List combinedBytes = Uint8List.fromList([
        ...ephemeralPublicKeyBytes,
        ...secretBox.concatenation(mac: true, nonce: true),
      ]);

      // 5. Encode the result as Base64
      return base64Encode(combinedBytes);
    } catch (e) {
      debugPrint('EncryptionService: Encryption failed: $e');
      return null;
    }
  }

  /// Decrypts data that was encrypted using our public key.
  ///
  /// Expects Base64 encoded string containing:
  /// EphemeralPublicKeyBytes(32) + Nonce(12) + Ciphertext + MAC(16)
  /// Returns the original string, or null on failure.
  Future<String?> decrypt(String encryptedDataB64) async {
    try {
      final combinedBytes = base64Decode(encryptedDataB64);

      // 1. Get our X25519 private key
      final myKeyPair = await _getMyX25519KeyPair();
      if (myKeyPair == null) {
        debugPrint(
            'EncryptionService: Could not retrieve own key pair for decryption.');
        return null;
      }

      // 2. Extract the ephemeral public key
      if (combinedBytes.length < _x25519PublicKeySize) {
        debugPrint(
            'EncryptionService: Encrypted data too short (no public key).');
        return null;
      }
      final ephemeralPublicKeyBytes =
          combinedBytes.sublist(0, _x25519PublicKeySize);
      final ephemeralPublicKey =
          SimplePublicKey(ephemeralPublicKeyBytes, type: KeyPairType.x25519);

      // 3. Extract the actual encrypted payload (SecretBox data)
      final secretBoxBytes = combinedBytes.sublist(_x25519PublicKeySize);

      // Check if remaining bytes are enough for nonce + mac
      if (secretBoxBytes.length < _chachaNonceSize + _poly1305MacSize) {
        debugPrint(
            'EncryptionService: Encrypted data too short (no nonce/mac).');
        return null;
      }

      // 4. Perform key agreement: our private key <-> ephemeral public key
      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: myKeyPair,
        remotePublicKey: ephemeralPublicKey,
      );

      // 5. Reconstruct the SecretBox from the concatenated bytes
      final secretBox = SecretBox.fromConcatenation(
        secretBoxBytes,
        nonceLength: _chachaNonceSize,
        macLength: _poly1305MacSize,
      );

      // 6. Decrypt the data using the shared secret
      final decryptedBytes = await _aeadAlgorithm.decrypt(
        secretBox,
        secretKey: sharedSecret,
      );

      // 7. Decode the result bytes back to a UTF-8 string
      return utf8.decode(decryptedBytes);
    } on SecretBoxAuthenticationError {
      // Specific error for MAC validation failure (tampering/wrong key)
      debugPrint(
          'EncryptionService: Decryption failed (authentication error).');
      return null;
    } catch (e) {
      // Other potential errors (e.g., base64 decoding, key derivation)
      debugPrint('EncryptionService: Decryption failed: $e');
      return null;
    }
  }
}
