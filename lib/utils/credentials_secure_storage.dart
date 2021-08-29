import 'dart:convert';

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

  static Future setSaveSheetID(String save) async =>
      await _storage.write(key: SAVE_SHEET_ID_KEY, value: save);

  static Future<String?> getSaveSheetID() async =>
      await _storage.read(key: SAVE_SHEET_ID_KEY);

  static Future setSettings(Map settings) async =>
      await _storage.write(key: SAVE_SHEET_ID_KEY, value: jsonEncode(settings));

  static Future<dynamic> getSettings() async {
    var settingsString = await _storage.read(key: SAVE_SHEET_ID_KEY);
    if (settingsString == null) {
      return false;
    }
    return jsonDecode(settingsString);
  }

  static Future<void> deleteAll() async {
    var saveSheetID = await getSaveSheetID();
    if (saveSheetID == 'true') {
      await _storage.delete(key: CREDENTIALS_KEY);
    } else {
      await _storage.deleteAll();
    }
  }
}
