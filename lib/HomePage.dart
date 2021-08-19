import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:member_statement/APICalls';
import "package:collection/collection.dart";
import 'package:member_statement/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.currentIpAddress);

  @override
  _HomePageState createState() => _HomePageState();
  final String currentIpAddress;
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
  String loansLabel = 'Loans';

  bool ipIsSet = false;

  @override
  void initState() {
    super.initState();
    if (!(widget.currentIpAddress == null || widget.currentIpAddress.isEmpty)) {
      setState(() {
        ipIsSet = true;
      });
    }
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
      child: widget.currentIpAddress == null
          ? Scaffold(
              appBar: AppBar(
                title: Text('Home'),
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: AppBarIcon(
                      icon: Icons.settings,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );

                      },
                    ),
                  )
                ],
              ),
            )
          : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text('Fetching from:  ${widget.currentIpAddress} '),
                centerTitle: true,
                elevation: 0,
                leading: AppBarIcon(
                  icon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: AppBarIcon(
                      icon: Icons.settings,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );
                      },
                    ),
                  )
                ],
              ),
              body: Stack(
                children: [
                  Container(
                    height: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1 / 10,
                      ),
                      buildNeuCard(
                        context,
                        Column(
                          children: [
                            buildInputArea(),
                            buildChoiceButtons(context)
                          ],
                        ),
                      ),
                      requestedBalances
                          ? FutureBuilder(
                              future: API().getBalancesByIdNo(
                                widget.currentIpAddress,
                                inputController.text,
                              ),
                              builder: (BuildContext context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    bool containsError =
                                        snapshot.data.containsKey("errorText");
                                    return containsError
                                        ? snapshot.data['errorText'] ==
                                                "Record not found!"
                                            ? buildNoRecordsFound()
                                            : buildConnectionError(
                                                snapshot.data['errorText'])
                                        : balancesView(snapshot, context);
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
                                      widget.currentIpAddress,
                                      inputController.text,
                                      docIdInput),
                                  builder: (BuildContext context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        bool containsError = snapshot.data
                                            .containsKey("errorText");
                                        bool containsSqlError = snapshot.data
                                            .containsKey("sqlErrorText");
                                        print(containsSqlError);

                                        return containsError
                                            ? buildConnectionError(
                                                snapshot.data['errorText'])
                                            : containsSqlError
                                                ? buildNoRecordsFound()
                                                : depositsSelected
                                                    ? sharesStatementView(
                                                        snapshot, context)
                                                    : loansStatementView(
                                                        snapshot, context);
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

  sharesStatementView(AsyncSnapshot<dynamic> snapshot, BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    var sharesList = snapshot.data['Statement'];
    sharesList.sort((a, b) {
      int schemeCompare = a['Scheme']
          .toString()
          .toLowerCase()
          .compareTo(b['Scheme'].toString().toLowerCase());

      if (schemeCompare != 0) return schemeCompare;

      DateFormat format = DateFormat("dd/MM/yyyy");
      return format.parse(a['DocDate']).compareTo(format.parse(b['DocDate']));
    });

    var newMap = groupBy(sharesList, (obj) => obj['Scheme']);

    return ListView.builder(
        shrinkWrap: true,
        itemCount: newMap.length,
        itemBuilder: (context, index) {
          String key = newMap.keys.elementAt(index);
          return buildNeuCard(
              context,
              ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildDTHeader('DATE'),
                        buildDTHeader('DESCRIPTION'),
                        buildDTHeader('AMOUNT'),
                      ],
                    ),
                    color: Colors.indigo,
                  ),
                  new ListTile(
                    title: new Text(
                      "Scheme Code : $key",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.separated(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: width * 1 / 4,
                                child: Text(snapshot.data['Statement'][index]['DocDate'])),
                            Container(
                                width: width * 2 / 4,
                                child: Text(snapshot.data['Statement'][index]['DocDesc'])),
                            Container(
                                width: width * 0.5 / 4,
                                child: Text(snapshot.data['Statement'][index]['DocAmount'])),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        Divider(height: 0.5, color: Colors.grey),
                    physics: PageScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: newMap[key].length,
                  )
                ],
              ));
        });

    // return buildNeuCard(
    //     context,
    //     ListView(
    //       shrinkWrap: true,
    //       children: [
    //         Container(
    //           height: 30,
    //           padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               buildDTHeader('DATE'),
    //               buildDTHeader('DESCRIPTION'),
    //               buildDTHeader('AMOUNT'),
    //             ],
    //           ),
    //           color: Colors.indigo,
    //         ),
    //         ListView.separated(
    //           separatorBuilder: (context, index) =>
    //               Divider(height: 0.5, color: Colors.grey),
    //           physics: PageScrollPhysics(),
    //           scrollDirection: Axis.vertical,
    //           shrinkWrap: true,
    //           itemCount: snapshot.data.length,
    //           itemBuilder: (context, index) {
    //             return Padding(
    //               padding: EdgeInsets.only(top: 8, bottom: 8, left: 10),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Container(
    //                       width: width * 1 / 4,
    //                       child: Text(snapshot.data[index]['DocDate'])),
    //                   Container(
    //                       width: width * 2 / 4,
    //                       child: Text(snapshot.data[index]['DocDesc'])),
    //                   Container(
    //                       width: width * 0.5 / 4,
    //                       child: Text(snapshot.data[index]['DocAmount'])),
    //                 ],
    //               ),
    //             );
    //           },
    //         ),
    //       ],
    //     ));
  }

  loansStatementView(AsyncSnapshot<dynamic> snapshot, BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    var loansList = snapshot.data['Statement'];

    loansList.sort((a, b) {
      int serialCompare = a['ReferenceCode']
          .toString()
          .toLowerCase()
          .compareTo(b['ReferenceCode'].toString().toLowerCase());

      if (serialCompare != 0) return serialCompare;

      DateFormat format = DateFormat("dd/MM/yyyy");

      return format.parse(a['DocDate']).compareTo(format.parse(b['DocDate']));
    });

    var newMap = groupBy(loansList, (obj) => obj['ReferenceCode']);
    print(newMap);
    // loansLabel='Loans (${newMap.length})';

    return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          String key = newMap.keys.elementAt(index);
          return buildNeuCard(
            context,
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 30,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildDTHeader('DATE'),
                      buildDTHeader('DESCRIPTION'),
                      buildDTHeader('AMOUNT'),
                    ],
                  ),
                  color: Colors.indigo,
                ),
                new ListTile(
                  title: new Text(
                    "Loan ID : $key",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(height: 0.5, color: Colors.grey),
                  physics: PageScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: newMap[key].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4, left: 10),
                      child: (Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: width * 1 / 4,
                              child: Text(newMap[key][index]['DocDate'])),
                          Container(
                              width: width * 2 / 4,
                              child: Text(newMap[key][index]['DocDesc'])),
                          Container(
                              width: width * 0.5 / 4,
                              child: Text(newMap[key][index]['DocAmount'])),
                        ],
                      )),
                    );
                  },
                ),
              ],
            ),
          );
        },
        itemCount: newMap.length);
  }

  Text buildDTHeader(header) => Text(
        header,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      );

  balancesView(AsyncSnapshot<dynamic> snapshot, BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return buildNeuCard(
        context,
        ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 30,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildDTHeader('ACCOUNT NAME'),
                  buildDTHeader('DESCRIPTION'),
                  buildDTHeader('BALANCE'),
                ],
              ),
              color: Colors.indigo,
            ),
            ListView.separated(
              separatorBuilder: (context, index) =>
                  Divider(height: 0.5, color: Colors.grey),
              physics: PageScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: width * 1 / 4,
                          child: Text(
                              snapshot.data['BalType'][index]['AccountName'])),
                      Container(
                          width: width * 2 / 4,
                          child: Text(
                              snapshot.data['BalType'][index]['Description'])),
                      Container(
                          width: width * 0.5 / 4,
                          child:
                              Text(snapshot.data['BalType'][index]['Balance'])),
                    ],
                  ),
                );
              },
            ),
          ],
        ));
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

  buildConnectionError(String cause) {
    return buildNeuCard(
      context,
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off_sharp,
              size: 90,
              color: Colors.grey,
            ),
            Text(
              'Connection failed...',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$cause',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  buildNoIPAddressYet() {
    return buildNeuCard(
      context,
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off_rounded,
              size: 90,
              color: Colors.grey,
            ),
            Text(
              'No IP Address Selected...',
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
          balancesSelected ? Icons.refresh_outlined : Icons.search,
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
          depositsSelected ? Icons.refresh_outlined : Icons.search,
        ),
        buildButton(
          context,
          loansLabel,
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
          loansSelected ? Icons.refresh_outlined : Icons.search,
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
      BuildContext context, String label, onPressed, color, fontColor, icon) {
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
                    icon,
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

class AppBarIcon extends StatelessWidget {
  final icon;
  final Function onPressed;

  AppBarIcon({Key key, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      margin: EdgeInsets.only(top: 0, left: 9, right: 0),
      onPressed: onPressed,
      padding: const EdgeInsets.all(12.0),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
        depth: -3,
        intensity: 0.8,
        color: Colors.indigo,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
