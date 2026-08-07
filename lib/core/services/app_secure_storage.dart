import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const appSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    migrateOnAlgorithmChange: true,
    migrateWithBackup: true,
  ),
);
