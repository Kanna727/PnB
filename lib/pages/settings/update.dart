import 'package:flutter/material.dart';
import 'package:portfolio_n_budget/api/localAuth.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/settings.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';
import 'package:portfolio_n_budget/widgets/spinningIconButton.dart';

const list = [
  {
    "title": UI_TEXTS.WORKSHEET_TITLES,
    "settingsKey": "worksheetTitles",
    "subSettings": [
      {
        "title": WORKSHEET_TITLES.ASSET_MANAGEMENT,
        "settingsKey": "assetManagement",
        "type": TextInputType.text
      },
      {
        "title": WORKSHEET_TITLES.TRANSACTIONS,
        "settingsKey": "transactions",
        "type": TextInputType.text
      },
      {
        "title": WORKSHEET_TITLES.DEBTS,
        "settingsKey": "debts",
        "type": TextInputType.text
      },
    ]
  },
  {
    "title": UI_TEXTS.TYPES_MASTER_COLUMNS,
    "settingsKey": "typesMasterColumns",
    "subSettings": [
      {
        "title": TYPES_CLASS.INCOME,
        "settingsKey": TYPES_CLASS.INCOME,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.EXPENSE,
        "settingsKey": TYPES_CLASS.EXPENSE,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.LIABILITY,
        "settingsKey": TYPES_CLASS.LIABILITY,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.SAVINGS,
        "settingsKey": TYPES_CLASS.SAVINGS,
        "type": TextInputType.number
      },
    ]
  },
  {
    "title": UI_TEXTS.TYPES_DESTINATION_COLUMNS,
    "settingsKey": "typesDestinationColumns",
    "subSettings": [
      {
        "title": TYPES_CLASS.INCOME,
        "settingsKey": TYPES_CLASS.INCOME,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.EXPENSE,
        "settingsKey": TYPES_CLASS.EXPENSE,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.LIABILITY,
        "settingsKey": TYPES_CLASS.LIABILITY,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.SAVINGS,
        "settingsKey": TYPES_CLASS.SAVINGS,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.SELF_TRANSFER,
        "settingsKey": TYPES_CLASS.SELF_TRANSFER,
        "type": TextInputType.number
      },
      {
        "title": TYPES_CLASS.REWARD_POINTS,
        "settingsKey": TYPES_CLASS.REWARD_POINTS,
        "type": TextInputType.number
      },
    ]
  },
  {
    "title": UI_TEXTS.BALANCES_TABLE,
    "settingsKey": "balancesTable",
    "subSettings": [
      {
        "title": UI_TEXTS.FROM_ROW,
        "settingsKey": "fromRow",
        "type": TextInputType.number
      },
      {
        "title": UI_TEXTS.FROM_COLUMN,
        "settingsKey": "fromColumn",
        "type": TextInputType.number
      },
      {
        "title": UI_TEXTS.COLUMNS_LENGTH,
        "settingsKey": "columnsLength",
        "type": TextInputType.number
      },
    ]
  },
  {
    "title": "Totals Table",
    "settingsKey": "totalsTable",
    "subSettings": [
      {
        "title": UI_TEXTS.FROM_ROW,
        "settingsKey": "fromRow",
        "type": TextInputType.number
      },
      {
        "title": UI_TEXTS.FROM_COLUMN,
        "settingsKey": "fromColumn",
        "type": TextInputType.number
      },
      {
        "title": UI_TEXTS.COLUMNS_LENGTH,
        "settingsKey": "columnsLength",
        "type": TextInputType.number
      },
    ]
  },
  {
    "title": UI_TEXTS.DEBTS_TABLE,
    "settingsKey": "debtsTable",
    "subSettings": [
      {
        "title": UI_TEXTS.FROM_ROW,
        "settingsKey": "fromRow",
        "type": TextInputType.number
      },
    ]
  },
  {
    "title": UI_TEXTS.START_ROWS,
    "settingsKey": "startRows",
    "subSettings": [
      {
        "title": WORKSHEET_TITLES.TRANSACTIONS,
        "settingsKey": "transactions",
        "type": TextInputType.number
      },
      {
        "title": WORKSHEET_TITLES.ASSET_MANAGEMENT,
        "settingsKey": "assetManagementSheet",
        "type": TextInputType.number
      },
    ]
  },
];

class UpdateSettings extends StatefulWidget {
  final updateSettingsCallback;
  UpdateSettings({required this.updateSettingsCallback, Key? key})
      : super(key: key);

  @override
  _UpdateSettingsState createState() => _UpdateSettingsState();
}

class _UpdateSettingsState extends State<UpdateSettings>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController =
      AnimationController(duration: Duration(seconds: 1), vsync: this);
  Settings settings = new Settings();
  bool settingsLoading = true;

  @override
  void initState() {
    super.initState();
    initSettings();
  }

  @override
  void dispose() {
    super.dispose();
    _rotateController.dispose();
  }

  initSettings() async {
    setState(() {
      settingsLoading = true;
    });
    await settings.initSettings();
    setState(() {
      settingsLoading = false;
    });
  }

  restore() async {
    setState(() {
      settingsLoading = true;
    });
    _rotateController.repeat();
    await settings.restore();
    _rotateController.forward(from: _rotateController.value);
    setState(() {
      settingsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UI_TEXTS.SETTINGS),
        centerTitle: true,
        actions: [
          Tooltip(
              message: UI_TEXTS.RESTORE_DEFAULTS,
              child: SpinningIconButton(
                controller: _rotateController,
                iconData: Icons.settings_backup_restore,
                onPressed: _showRestoreConfirmationDialog,
              )),
        ],
      ),
      body: settingsLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                return ExpansionTile(
                  maintainState: true,
                  title: Text(list[i]["title"].toString()),
                  children: <Widget>[
                    new Column(
                      children: _buildExpandableContent(list[i]),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.save,
        ),
        onPressed: () async {
          var sheetID = await CredentialsSecureStorage.getSheetID();
          if (sheetID != DEMO_SHEET_ID) {
            final isAuthenticated = await LocalAuthApi.authenticate();
            if (!isAuthenticated) {
              return;
            }
          }
          await settings.update();
          await widget.updateSettingsCallback();
        },
      ),
    );
  }

  _buildExpandableContent(setting) {
    List<Widget> columnContent = [];

    for (var subSetting in setting["subSettings"])
      columnContent.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            key: Key(settings.settings[setting["settingsKey"]]
                    [subSetting["settingsKey"]]
                .toString()),
            initialValue: settings.settings[setting["settingsKey"]]
                    [subSetting["settingsKey"]]
                .toString(),
            decoration: InputDecoration(labelText: subSetting["title"]),
            keyboardType: subSetting["type"],
            onChanged: (text) {
              settings.settings[setting["settingsKey"]]
                      [subSetting["settingsKey"]] =
                  subSetting["type"] == TextInputType.number
                      ? int.parse(text)
                      : text;
            },
          ),
        ),
      );

    return columnContent;
  }

  Future<void> _showRestoreConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [
            Icon(Icons.warning_amber, color: Colors.amber),
            Text(UI_TEXTS.CONFIRM_RESTORE_TITLE)
          ]),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(UI_TEXTS.CONFIRM_RESTORE_MESSAGE),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(UI_TEXTS.RESTORE),
              onPressed: () async {
                Navigator.pop(context);
                var sheetID = await CredentialsSecureStorage.getSheetID();
                if (sheetID != DEMO_SHEET_ID) {
                  final isAuthenticated = await LocalAuthApi.authenticate();
                  if (!isAuthenticated) {
                    return;
                  }
                }
                await restore();
              },
            ),
          ],
        );
      },
    );
  }
}
