import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:portfolio_n_budget/api/gsheets.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';
import 'package:portfolio_n_budget/api/localAuth.dart';

import 'pages/balances/overview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  var _pageController = PageController();
  TextEditingController _sheetIDController = TextEditingController();
  TextEditingController _credentialsController = TextEditingController();

  @override
  void initState() {
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
      final isAuthenticated = await LocalAuthApi.authenticate();
      if(isAuthenticated) {
        setState(() {
          checkingCredentials = false;
        });
      }
    }
  }

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
            : BalancesOverview(),
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
