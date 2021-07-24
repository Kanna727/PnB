import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:portfolio_n_budget/api/gsheets.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';

import 'pages/transactions/add.dart';
import 'pages/balances/overview.dart';
import 'widgets/frostedBottomNavBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // to hide the status bar
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Portfolio & Budget',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool checkingCredentials = true;
  bool awaitingCredentials = false;
  int _selectedIndex = 0;
  var _pageController = PageController();
  TextEditingController _sheetIDController = TextEditingController();
  TextEditingController _credentialsController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCredentials();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getCredentials() async {
    var credentials = await CredentialsSecureStorage.getCredentials();

    if (credentials == null) {
      setState(() {
        awaitingCredentials = true;
      });
    } else {
      setState(() {
        checkingCredentials = false;
      });
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    BalancesOverview(),
    Padding(
      padding: EdgeInsets.only(bottom: 65),
      child: AddTransaction(),
    ),
  ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //     _pageController.animateToPage(_selectedIndex,
  //         duration: Duration(milliseconds: 200), curve: Curves.linear);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: checkingCredentials == true
            ? Center(
                child: !awaitingCredentials
                    ? CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Spreasheet credential required',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _sheetIDController.text = value;
                                });
                              },
                              decoration: InputDecoration(hintText: "Sheet ID"),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              enabled: _sheetIDController.text != "",
                              onChanged: (value) {
                                setState(() {
                                  _credentialsController.text = value;
                                });
                              },
                              decoration:
                                  InputDecoration(hintText: "Credential"),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          )
                        ],
                      ),
              )
            : Stack(
                children: <Widget>[
                  _widgetOptions.elementAt(_selectedIndex),
                  // PageView(
                  //   //scrollDirection: Axis.vertical,
                  //   children: _widgetOptions,
                  //   onPageChanged: (index) {
                  //     setState(() {
                  //       _selectedIndex = index;
                  //     });
                  //   },
                  //   controller: _pageController,
                  // ),
                  // FrostedBottomNavBar(
                  //     bottomNavigationBarItems: const <BottomNavigationBarItem>[
                  //       BottomNavigationBarItem(
                  //           icon: Icon(Icons.account_balance), label: 'Balances'),
                  //       BottomNavigationBarItem(
                  //         icon: Icon(Icons.receipt),
                  //         label: 'Trasanctions',
                  //       ),
                  //     ],
                  //     currentIndex: _selectedIndex,
                  //     onIndexChange: (val) {
                  //       _onItemTapped(val);
                  //     }),
                ],
              ),
        floatingActionButton: Visibility(
            visible: awaitingCredentials,
            child: FloatingActionButton(
              backgroundColor:
                  _credentialsController.text == "" ? Colors.grey : null,
              onPressed: _credentialsController.text == ""
                  ? null
                  : () async {
                      try {
                        setState(() {
                          awaitingCredentials = false;
                        });
                        final gsheets = GSheets(_credentialsController.text);
                        var spreadsheet =
                            await gsheets.spreadsheet(_sheetIDController.text);

                        spreadsheet.worksheetByTitle(
                            WORKSHEET_TITLES.ASSET_MANAGEMENT);
                        await CredentialsSecureStorage.setCredentials(
                            _credentialsController.text);
                        await CredentialsSecureStorage.setSheetID(
                            _sheetIDController.text);
                        setState(() {
                          checkingCredentials = false;
                        });
                      } catch (err) {
                        setState(() {
                          awaitingCredentials = true;
                        });
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              // Retrieve the text the that user has entered by using the
                              // TextEditingController.
                              content: Text("Incorrect credentials"),
                            );
                          },
                        );
                      }
                    },
              tooltip: 'Show me the value!',
              child: const Icon(Icons.save),
            )));
  }
}
