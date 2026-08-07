import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared secure storage instance for the whole app.
///
/// [ApiConfig] and [JwtService] both read/write through this single instance
/// so the platform options can never drift apart — a mixed-mode setup would
/// make values written by one instance invisible to the other.
///
/// Android: uses the modern custom-cipher storage (the v10 default) — AES/GCM
/// for data, RSA/OAEP-SHA256 for Android KeyStore key wrapping. The ciphers
/// are pinned explicitly so a future plugin default change cannot silently
/// weaken storage. Data written by older plugin versions (legacy AES/CBC or
/// EncryptedSharedPreferences) is re-encrypted to the current cipher
/// automatically on first access ([KeyCipherAlgorithm] /
/// [StorageCipherAlgorithm] migration), with crash-safe backups
/// (migrateWithBackup).
///
/// iOS/macOS: these options are a no-op; storage is always the Keychain.
/// Windows/Linux: DPAPI / libsecret.
const appSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    migrateOnAlgorithmChange: true,
    migrateWithBackup: true,
  ),
);
