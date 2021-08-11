import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:member_statement/APICalls';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dropdownValue = 'Member Number';

  bool loansSelected = false;
  bool depositsSelected = false;
  bool balancesSelected = false;

  final inputController = TextEditingController();
  String docIdInput = '';

  var balancesFuture;
  var statementFuture;

  bool requestedBalances = false;
  bool requestedStatement = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure you want to exit ?'),
            titlePadding:
                EdgeInsets.only(top: 15, bottom: 5, left: 20, right: 20),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'Cancel',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text(
                  'Exit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Member Details."),
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              height: 80,
              color: Theme.of(context).primaryColor,
            ),
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.1/10,),
                buildNeuCard(
                  context,
                  Column(
                    children: [buildInputArea(), buildChoiceButtons(context)],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: requestedBalances
                        ? FutureBuilder(
                            future: API().getBalancesByIdNo(inputController.text),
                            builder: (BuildContext context, snapshot) {
                              print('data: ');
                              print(snapshot.data);
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  return balancesDataTable(snapshot, context);
                                }
                                if (!snapshot.hasData) {
                                  return buildNoRecordsFound();
                                }
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return buildLoading(context);
                              }

                              return Center();
                            })
                        : requestedStatement
                            ? FutureBuilder(
                                future: API().getStatementByIdNo(
                                    inputController.text, docIdInput),
                                builder: (BuildContext context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      return statementDataTable(snapshot, context);
                                    }
                                    if (!snapshot.hasData) {
                                      return buildNoRecordsFound();
                                    }
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return buildLoading(context);
                                  }

                                  return Center();
                                })
                            : buildSearchAbove(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildSearchAbove() {
    return buildNeuCard(
      context,
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 90,
              color: Colors.grey,
            ),
            Text(
              'Search Id Number Above...',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  statementDataTable(AsyncSnapshot<dynamic> snapshot, BuildContext context) {
    return buildNeuCard(
      context,
      DataTable(
        columnSpacing: 10.0,
        columns: [
          buildDataColumn('DATE'),
          buildDataColumn('DESCRIPTION'),
          buildDataColumn('AMOUNT'),
        ],
        rows: List.generate(snapshot.data.length, (index) {
          final docDate = snapshot.data[index]['DocDate'];
          final docDesc = snapshot.data[index]['DocDesc'];
          final docAmount = snapshot.data[index]['DocAmount'];
          return DataRow(cells: [
            DataCell(Container(
                width: MediaQuery.of(context).size.width / 5,
                child: Text('$docDate'))),
            DataCell(Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Text('$docDesc'))),
            DataCell(Container(
                width: MediaQuery.of(context).size.width / 6,
                child: Text('$docAmount'))),
          ]);
        }),
      ),
    );
  }

  balancesDataTable(AsyncSnapshot<dynamic> snapshot, BuildContext context) {
    return buildNeuCard(
      context,
      DataTable(
        columnSpacing: 10.0,
        columns: [
          // buildDataColumn('Doc ID: '),
          buildDataColumn('DESCRIPTION'),
          buildDataColumn('BALANCE'),
          // buildDataColumn('Ref Code: '),
          buildDataColumn('ACCOUNT NAME'),
        ],
        rows: List.generate(snapshot.data.length, (index) {
          final docId = snapshot.data[index]['DocID'];
          final description = snapshot.data[index]['Description'];
          final balance = snapshot.data[index]['Balance'];
          final refCode = snapshot.data[index]['RefCode'];
          final accountName = snapshot.data[index]['AccountName'];

          return DataRow(cells: [
            // DataCell(
            //     Container(width: 40, child: Text('$docId'))),
            DataCell(Container(
                width: MediaQuery.of(context).size.width / 3,
                child: Text('$description'))),
            DataCell(Container(
                width: MediaQuery.of(context).size.width / 5,
                child: Text('$balance'))),
            // DataCell(Container(width: 40,child: Text('$refCode'))),
            DataCell(Container(
                width: MediaQuery.of(context).size.width / 3,
                child: Text('$accountName'))),
          ]);
        }),
      ),
    );
  }

  buildLoading(BuildContext context) {
    return buildNeuCard(
      context,
      Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  buildNoRecordsFound() {
    return buildNeuCard(
      context,
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 90,
              color: Colors.grey,
            ),
            Text(
              'No Records Found...',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Row buildChoiceButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildButton(
          context,
          'Balances',
          () {
            FocusManager.instance.primaryFocus.unfocus();
            setState(() {
              balancesSelected = true;
              loansSelected = false;
              depositsSelected = false;

              requestedBalances = true;
              requestedStatement = false;
            });
          },
          balancesSelected ? Colors.indigo : Colors.white,
          balancesSelected ? Colors.white : Colors.indigo,
        ),
        buildButton(
          context,
          'Shares ',
          () {
            FocusManager.instance.primaryFocus.unfocus();
            setState(() {
              balancesSelected = false;
              loansSelected = false;
              depositsSelected = true;

              requestedStatement = true;
              requestedBalances = false;
              docIdInput = 'S';
            });
          },
          depositsSelected ? Colors.indigo : Colors.white,
          depositsSelected ? Colors.white : Colors.indigo,
        ),
        buildButton(
          context,
          'Loans ',
          () {
            FocusManager.instance.primaryFocus.unfocus();
            setState(() {
              balancesSelected = false;
              loansSelected = true;
              depositsSelected = false;

              requestedStatement = true;
              requestedBalances = false;
              docIdInput = 'L';
            });
          },
          loansSelected ? Colors.indigo : Colors.white,
          loansSelected ? Colors.white : Colors.indigo,
        ),
      ],
    );
  }

  DataColumn buildDataColumn(label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Padding buildNeuCard(BuildContext context, child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Neumorphic(
        style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
            depth: -1.5,
            intensity: 0.8,
            lightSource: LightSource.topLeft,
            color: Colors.white),
        child: child,
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
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
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
      padding: new EdgeInsets.only(top: 25, bottom: 10, left: 12, right: 12),
      child: new TextField(
        onSubmitted: (newValue) {
          FocusManager.instance.primaryFocus.unfocus();
        },
        keyboardType: TextInputType.number,
        controller: inputController,
        style: TextStyle(fontSize: 16.0, color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Member ID Number...',
          // suffixIcon: Icon(Icons.search,size: 5,),
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
              width: MediaQuery.of(context).size.width / 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: fontColor,
                  ),
                  Text(
                    label,
                    style: TextStyle(color: fontColor, fontSize: 14),
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
