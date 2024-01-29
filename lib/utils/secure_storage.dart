import 'package:biometric_login/model/login_credential.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  writeLoginCredential(String username, String password, String secretKey,
      String checksum) async {
    await _storage.write(key: "username", value: username);
    await _storage.write(key: "password", value: password);
    await _storage.write(key: "secret_key", value: secretKey);
    await _storage.write(key: "checksum", value: checksum);
  }

  Future<LoginCredential?> readLoginCredential() async {
    String? username = await _storage.read(key: "username");
    String? password = await _storage.read(key: "password");
    String? secretKey = await _storage.read(key: "secret_key");
    String? checksum = await _storage.read(key: "checksum");
    if (username == null ||
        password == null ||
        secretKey == null ||
        checksum == null) {
      return null;
    }
    return LoginCredential(
        username: username,
        password: password,
        secretKey: secretKey,
        checksum: checksum);
  }
}
