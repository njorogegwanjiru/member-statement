import 'package:flutter/material.dart';
import 'package:member_statement/HomePage.dart';
import 'package:member_statement/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var ipAddress = sharedPreferences.getString('currentIp');
  print('ip address is set to: $ipAddress');

  runApp(MaterialApp(
    home: ipAddress == null ? Settings() : HomePage(ipAddress),
    debugShowCheckedModeBanner: false,
    title: 'Get Member Statement',
    theme: ThemeData(
      primarySwatch: Colors.indigo,
    ),
  ));
}

