import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolio_n_budget/constants.dart';

class CredentialsSecureStorage {
  static final _storage = FlutterSecureStorage();

  static Future setCredentials(String credentials) async =>
      await _storage.write(key: CREDENTIALS_KEY, value: credentials);

  static Future<String?> getCredentials() async =>
      await _storage.read(key: CREDENTIALS_KEY);

  static Future setSheetID(String sheetID) async =>
      await _storage.write(key: SHEET_ID_KEY, value: sheetID);

  static Future<String?> getSheetID() async =>
      await _storage.read(key: SHEET_ID_KEY);
}