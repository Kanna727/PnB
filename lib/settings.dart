import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';

class Settings {
  var settings;
  var _defaultSettings = {
    "worksheetTitles": {
      "assetManagement": WORKSHEET_TITLES.ASSET_MANAGEMENT,
      "transactions": WORKSHEET_TITLES.TRANSACTIONS,
      "debts": WORKSHEET_TITLES.DEBTS,
    },
    "typesMasterColumns": {
      "Income": TYPES_MASTER_COLUMNS[TYPES_CLASS.INCOME],
      "Expense": TYPES_MASTER_COLUMNS[TYPES_CLASS.EXPENSE],
      "Liability": TYPES_MASTER_COLUMNS[TYPES_CLASS.LIABILITY],
      "Savings": TYPES_MASTER_COLUMNS[TYPES_CLASS.SAVINGS],
    },
    "typesDestinationColumns": {
      "Income": TYPES_DESTINATION_COLUMNS[TYPES_CLASS.INCOME],
      "Expense": TYPES_DESTINATION_COLUMNS[TYPES_CLASS.EXPENSE],
      "Liability": TYPES_DESTINATION_COLUMNS[TYPES_CLASS.LIABILITY],
      "Savings": TYPES_DESTINATION_COLUMNS[TYPES_CLASS.SAVINGS],
      "Self Transfer": TYPES_DESTINATION_COLUMNS[TYPES_CLASS.SELF_TRANSFER],
      "Reward Points": TYPES_DESTINATION_COLUMNS[TYPES_CLASS.REWARD_POINTS],
    },
    "balancesTable": {
      "fromRow": BALANCES_TABLE.fromRow,
      "fromColumn": BALANCES_TABLE.fromColumn,
      "columnsLength": BALANCES_TABLE.columnsLength,
    },
    "totalsTable": {
      "fromRow": TOTALS_TABLE.fromRow,
      "fromColumn": TOTALS_TABLE.fromColumn,
      "columnsLength": TOTALS_TABLE.columnsLength,
    },
    "debtsTable": {
      "fromRow": DEBTS_TABLE.fromRow,
    },
    "startRows": {
      "transactions": TRANSACTIONS_START_ROW,
      "assetManagementSheet": ASSET_MANAGEMENT_SHEET_START_ROW,
    }
  };

  Settings({toInitSettings = false}) {
    if (toInitSettings) {
      initSettings();
    }
  }

  update() async {
    await initSettings();
  }

  restore() async {
    settings = _defaultSettings;
    await CredentialsSecureStorage.setSettings(settings);
  }

  initSettings() async {
    if (settings == null) {
      settings = await CredentialsSecureStorage.getSettings();
    }
    if (settings == false) {
      settings = _defaultSettings;
    }
    await CredentialsSecureStorage.setSettings(settings);
  }
}
