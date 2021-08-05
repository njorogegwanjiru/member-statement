import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dropdownValue = 'Member Number';
  bool loansSelected = true;
  bool depositsSelected = false;
  final inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Member Statement"),
        ),
        body: ListView(
          children: [
            Column(
              children: [
                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Column(
                      children: [
                        buildSelectModeArea(context),
                        buildInputArea(),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildButton(context, 'Loans', () {
                        setState(() {
                          loansSelected = !loansSelected;
                          depositsSelected = !loansSelected;
                        });
                      }, loansSelected ? Colors.indigo : Colors.white,
                          loansSelected ? Colors.white : Colors.indigo),
                      buildButton(context, 'Deposits', () {
                        setState(() {
                          depositsSelected = !depositsSelected;
                          loansSelected = !depositsSelected;
                        });
                      }, depositsSelected ? Colors.indigo : Colors.white,
                          depositsSelected ? Colors.white : Colors.indigo),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 1 / 2,
                  width: MediaQuery.of(context).size.width - 20,
                  child: buildDataTable(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding buildSelectModeArea(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        elevation: 5,
        child: Container(
          height: 30,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Search By...",
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                iconSize: 25,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Payroll Number', 'Member Number', 'ID Number']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildInputArea() {
    return Padding(
      padding: new EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: new TextField(
        keyboardType: TextInputType.number,
        controller: inputController,
        style: TextStyle(fontSize: 16.0, color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Enter ' + dropdownValue + ' here...',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  Padding buildButton(
      BuildContext context, String label, onPressed, color, fontColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: onPressed,
          child: Container(
              width: MediaQuery.of(context).size.width / 2 - 50,
              child: Center(
                  child: Text(
                label,
                style: TextStyle(color: fontColor, fontSize: 16),
              ))),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => color),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.indigo))))),
    );
  }

  DataTable buildDataTable() {
    return DataTable(
      columns: [
        DataColumn(
          label: Text(
            "Date",
            style: TextStyle(fontSize: 16),
          ),
        ),
        DataColumn(
          label: Text("Credit",
            style: TextStyle(fontSize: 16),),
        ),
        DataColumn(
          label: Text("Balance",
            style: TextStyle(fontSize: 16),),
        ),
      ],
      rows: [
        DataRow(
          cells: [
            DataCell(Text("04/08/2021",
              style: TextStyle(fontSize: 16),)),
            DataCell(Text("2,000",
              style: TextStyle(fontSize: 16),)),
            DataCell(Text("5,000",
              style: TextStyle(fontSize: 16),)),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text("04/08/2021",
              style: TextStyle(fontSize: 16),)),
            DataCell(Text("2,000",
              style: TextStyle(fontSize: 16),)),
            DataCell(Text("5,000",
              style: TextStyle(fontSize: 16),)),
          ],
        ),
      ],
    );
  }
}
