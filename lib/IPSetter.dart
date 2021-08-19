import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IPSetter extends ChangeNotifier {
  SharedPreferences sharedPreferences;
  String currentIp;

  ipNotifier() {
    currentIp = '';
    _loadFromPrefs();
  }

  _initPrefs() async {
    if (sharedPreferences == null)
      sharedPreferences = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    currentIp = sharedPreferences.getString('currentIP');
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    sharedPreferences.setString('currentIP', currentIp);
  }
}
