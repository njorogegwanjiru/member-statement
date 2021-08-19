import 'package:flutter/material.dart';
import 'package:member_statement/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String ipPattern = '/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/';
  final inputController = TextEditingController();

  bool ipInvalid = false;

  bool invalidInput(String value) {
    Pattern pattern = r'/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/';
    RegExp regex = new RegExp(pattern, caseSensitive: false);

    print(regex.hasMatch('41.139.160.55'));
    if (!regex.hasMatch(value))
      return true;
    else
      return false;
  }

  getCurrentIp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String setIp = prefs.getString('currentIp');
    if (setIp != null) {
      setState(() {
        inputController.text = setIp;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentIp();
    print('yooo ${inputController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarIcon(
          icon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Change IP Address'),
      ),
      body: Padding(
        padding: new EdgeInsets.only(top: 25, bottom: 10, left: 12, right: 12),
        child: Column(
          children: [
            TextField(
              onSubmitted: (newValue) {
                FocusManager.instance.primaryFocus.unfocus();
              },
              keyboardType: TextInputType.number,
              controller: inputController,
              style: TextStyle(fontSize: 16.0, color: Colors.black),
              decoration: InputDecoration(
                errorText: ipInvalid ? "Input is not a valid IP Address" : null,
                labelText: 'IP Address',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            buildButton(context, 'Connect to IP', () async {
              setState(() {
                (inputController.text.isEmpty)
                    ? ipInvalid = true
                    : ipInvalid = false;
              });

              if (!ipInvalid) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('currentIp', inputController.text);
                print('new ip: ${inputController.text}');

                onSaveSelected(inputController.text);
              }
            }, Colors.indigo, Colors.white, Icons.save_alt)
          ],
        ),
      ),
    );
  }

  onSaveSelected(String ipAddress) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Connect to:  $ipAddress?'),
        titlePadding: EdgeInsets.only(top: 15, bottom: 5, left: 20, right: 20),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: new Text(
              'Cancel',
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext ctx) =>
                          HomePage(inputController.text)));
            },
            child: new Text(
              'Confirm',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildButton(
      BuildContext context, String label, onPressed, color, fontColor, icon) {
    return Padding(
      padding: new EdgeInsets.only(top: 8),
      child: TextButton(
          onPressed: onPressed,
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: fontColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    label,
                    style: TextStyle(color: fontColor, fontSize: 18),
                  ),
                ],
              )),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => color),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.indigo))))),
    );
  }
}
