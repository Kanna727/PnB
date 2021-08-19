import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:portfolio_n_budget/api/gsheets.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';
import 'package:portfolio_n_budget/api/localAuth.dart';
import 'package:portfolio_n_budget/widgets/frostedDrawer.dart';

import 'pages/balances/overview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // to hide the status bar
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Portfolio & Budget',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

Route routes(RouteSettings settings) {
  if (settings.name == '/login') {
    return MaterialPageRoute(
      builder: (context) {
        return MyHomePage();
      },
    );
  } else {
    return MaterialPageRoute(
      builder: (context) {
        return MyHomePage();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
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
        checkingCredentials = true;
        awaitingCredentials = true;
      });
    } else {
      final isAuthenticated = await LocalAuthApi.authenticate();
      if (isAuthenticated) {
        setState(() {
          checkingCredentials = false;
        });
      }
    }
  }

  Future<void> _setCredentials({credentials, sheetID}) async {
    try {
      setState(() {
        awaitingCredentials = false;
      });
      final gsheets = GSheets(credentials ?? _credentialsController.text);
      var spreadsheet =
          await gsheets.spreadsheet(sheetID ?? _sheetIDController.text);

      spreadsheet.worksheetByTitle(WORKSHEET_TITLES.ASSET_MANAGEMENT);
      await CredentialsSecureStorage.setCredentials(
          credentials ?? _credentialsController.text);
      await CredentialsSecureStorage.setSheetID(
          sheetID ?? _sheetIDController.text);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawerScrimColor: Colors.transparent,
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
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                String credentials =
                                    await DefaultAssetBundle.of(context)
                                        .loadString(
                                            "assets/dummy_credentials.json");
                                await _setCredentials(
                                    credentials: credentials, sheetID: DEMO_SHEET_ID);
                              },
                              child: Text('Use Demo Sheet'))
                        ],
                      ),
              )
            : BalancesOverview(scaffoldKey: scaffoldKey),
        floatingActionButton: Visibility(
            visible: awaitingCredentials,
            child: FloatingActionButton(
              backgroundColor:
                  _credentialsController.text == "" ? Colors.grey : null,
              onPressed: _credentialsController.text == ""
                  ? null
                  : () async {
                      await _setCredentials();
                    },
              tooltip: 'Show me the value!',
              child: const Icon(Icons.save),
            )),
        drawer: FrostedDrawer(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Container(
                  child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Container(
                          child: Column(
                        children: <Widget>[
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.power_settings_new),
                            title: Text('Logout'),
                            onTap: () async {
                              await CredentialsSecureStorage.deleteAll();
                              _getCredentials();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ))))
            ],
          ),
        ));
  }
}
