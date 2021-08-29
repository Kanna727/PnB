import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:portfolio_n_budget/api/gsheets.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';
import 'package:portfolio_n_budget/api/localAuth.dart';
import 'package:portfolio_n_budget/widgets/frostedDrawer.dart';
import 'package:portfolio_n_budget/settings.dart';

import 'package:portfolio_n_budget/pages/balances/overview.dart';
import 'package:portfolio_n_budget/pages/settings/update.dart';

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
  bool saveSheetID = false;
  var _pageController = PageController();
  TextEditingController _sheetIDController = TextEditingController();
  TextEditingController _credentialsController = TextEditingController();
  Settings settings = new Settings(toInitSettings: true);

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
    var sheetID = await CredentialsSecureStorage.getSheetID();
    var _saveSheetID = await CredentialsSecureStorage.getSaveSheetID();

    if (credentials == null) {
      setState(() {
        _sheetIDController.text = sheetID ?? "";
        checkingCredentials = true;
        awaitingCredentials = true;
        saveSheetID = _saveSheetID == 'true' ? true : false;
      });
    } else if (sheetID != DEMO_SHEET_ID) {
      final isAuthenticated = await LocalAuthApi.authenticate();
      if (isAuthenticated) {
        setState(() {
          checkingCredentials = false;
        });
      }
    } else {
      setState(() {
        checkingCredentials = false;
      });
    }
  }

  Future<void> _setCredentials({credentials, sheetID, isDummy = false}) async {
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
      await CredentialsSecureStorage.setSaveSheetID(
          isDummy ? 'false' : saveSheetID.toString());
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
            content: Text(UI_TEXTS.INCORRECT_CREDENTIALS),
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
                          Text(UI_TEXTS.CREDENTIALS_REQUIRED,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _sheetIDController,
                              decoration:
                                  InputDecoration(labelText: "Sheet ID"),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _credentialsController.text = value;
                                });
                              },
                              decoration:
                                  InputDecoration(labelText: UI_TEXTS.CREDENTIAL),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                          CheckboxListTile(
                            title: Text(UI_TEXTS.SAVE_SHEET_ID),
                            value: saveSheetID,
                            onChanged: (newValue) {
                              setState(() {
                                saveSheetID = newValue!;
                              });
                            },
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                String credentials =
                                    await DefaultAssetBundle.of(context)
                                        .loadString(
                                            "assets/dummy_credentials.json");
                                await _setCredentials(
                                    credentials: credentials,
                                    sheetID: DEMO_SHEET_ID,
                                    isDummy: true);
                              },
                              child: Text(UI_TEXTS.USE_DEMO_SHEET))
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
                            leading: Icon(Icons.settings),
                            title: Text(UI_TEXTS.SETTINGS),
                            onTap: () async {
                              Navigator.pop(context);
                              await _showSettingsWarnDialog();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.power_settings_new),
                            title: Text(UI_TEXTS.LOGOUT),
                            onTap: () async {
                              Navigator.pop(context);
                              await _showLogoutWarnDialog();
                            },
                          ),
                        ],
                      ))))
            ],
          ),
        ));
  }

  Future<void> _showSettingsWarnDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [
            Icon(Icons.warning_amber, color: Colors.amber),
            Text(UI_TEXTS.SENSITIVE_SETTINGS)
          ]),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                      UI_TEXTS.SETTINGS_CAUTION),
                ),
                Text(
                    UI_TEXTS.SETTINGS_AUTHORIZE_SAVE),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(UI_TEXTS.PROCEED),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        UpdateSettings(updateSettingsCallback: () async {
                      await _getCredentials();
                      Navigator.of(context).pop();
                      // BalancesOverview.scaffoldKey.currentState._getData();
                    }),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLogoutWarnDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [
            Icon(Icons.warning_amber, color: Colors.amber),
            Text(UI_TEXTS.CONFIRM_LOGOUT_TITLE)
          ]),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(UI_TEXTS.CONFIRM_LOGOUT_MESSAGE),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(UI_TEXTS.LOGOUT),
              onPressed: () async {
                await CredentialsSecureStorage.deleteAll();
                _getCredentials();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
