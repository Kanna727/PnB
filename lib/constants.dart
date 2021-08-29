import 'package:intl/intl.dart';

const CREDENTIALS_KEY = '_ck';
const SHEET_ID_KEY = '_sid';
const SAVE_SHEET_ID_KEY = '_ssid';

const DEMO_SHEET_ID = '1EVXhh0ohA-nBv3KyeMkFssTEf0BSVG3S4yjKHVmmLaY';

class WORKSHEET_TITLES {
  static const ASSET_MANAGEMENT = "Asset Management";
  static const TRANSACTIONS = "Transactions";
  static const DEBTS = "Debts";
}

const TYPES = [
  "Income",
  "Expense",
  "Liability",
  "Savings",
  "Self Transfer",
  "Reward Points"
];

class TYPES_CLASS {
  static const INCOME = "Income";
  static const EXPENSE = "Expense";
  static const LIABILITY = "Liability";
  static const SAVINGS = "Savings";
  static const SELF_TRANSFER = "Self Transfer";
  static const REWARD_POINTS = "Reward Points";
}

const TYPES_MASTER_COLUMNS = {
  "Income": 16,
  "Expense": 19,
  "Liability": 1,
  "Savings": 22,
};

const TYPES_DESTINATION_COLUMNS = {
  "Income": 1,
  "Expense": 8,
  "Liability": 15,
  "Savings": 22,
  "Self Transfer": 30,
  "Reward Points": 38,
};

String getCurrencyFormat(String val) {
  return NumberFormat.currency(
          locale: LOCALE, symbol: CURRENCY_SYMBOL_WITH_SPACE.trim())
      .format(double.parse(val));
}

enum Positions {
  top,
  bottom,
}

const double EXPANDED_APP_BAR_HEIGHT = 310;
const double SEARCH_WIDGET_HEIGHT = 42;
const double ACCOUNT_CARDS_VERTICAL_MARGIN = 16;
const double ACCOUNT_CARDS_HORIZONTAL_MARGIN = 24;

class BALANCES_TABLE {
  static const fromRow = 3;
  static const fromColumn = 1;
  static const columnsLength = 7;
}

class TOTALS_TABLE {
  static const fromRow = 2;
  static const fromColumn = 13;
  static const columnsLength = 2;
}

const TRANSACTIONS_START_ROW = 3;

const String SALARY_DEDUCTION = "Salary Deduction";

const String DATE_FORMAT = "dd/MM/yyyy";
const String LOCALE = "en-IN";
const String CURRENCY_SYMBOL_WITH_SPACE = "₹ ";

class DEBTS_TABLE {
  static const fromRow = 2;
}

const ASSET_MANAGEMENT_SHEET_START_ROW = 2;

class UI_TEXTS {
  static const ADD_TRANSACTION = "Add Transaction";
  static const TYPE = "Type";
  static const TYPE_ERROR = 'Please select some type';
  static const DEBIT_ACCOUNT = "Debit Account";
  static const DEBIT_ACCOUNT_ERROR = 'Please select some debit account';
  static const CREDIT_ACCOUNT = "Credit Account";
  static const CREDIT_ACCOUNT_ERROR = 'Please select some credit account';
  static const ITEM = "Item";
  static const ITEM_ERROR = 'Please select some item';
  static const DATE = "Date";
  static const AMOUNT = "Amount";
  static const AMOUNT_ERROR = 'Please select some amount';
  static const POINTS = "Points";
  static const POINTS_ERROR = 'Please select some points';
  static const NOTE = "Note";
  static const NOTE_ERROR = 'Please select some note';
  static const TRANSACTION_SAVED = "Transaction saved";
  static const MAB_SHORTFALL = "MAB Shortfall";
  static const PERMISSION_ERROR =
      "You do not have enough permissions to perform this action";
  static const INCORRECT_CREDENTIALS = "Incorrect credentials";
  static const CREDENTIALS_REQUIRED = "Spreasheet credentials required";
  static const CREDENTIAL = "credential";
  static const SAVE_SHEET_ID = "Save Sheet ID";
  static const USE_DEMO_SHEET = 'Use Demo Sheet';
  static const SETTINGS = 'Settings';
  static const LOGOUT = 'Logout';
  static const SENSITIVE_SETTINGS = '  Sensitive Settings ';
  static const SETTINGS_CAUTION = 'The changes you are about to change are extremely sensitive and can alter your spreadsheet. Proceed with caution.';
  static const SETTINGS_AUTHORIZE_SAVE = "NOTE: As a security measure, every time you change any setting, you need authenticate yourself using your device's security";
  static const PROCEED = "Proceed";
  static const CONFIRM_LOGOUT_TITLE = '  Confirm Logout ';
  static const CONFIRM_LOGOUT_MESSAGE = "Are you sure you want to logout?";
  static const RESTORE_DEFAULTS = 'Restore Defaults';
  static const CONFIRM_RESTORE_TITLE = '  Confirm Restore ';
  static const CONFIRM_RESTORE_MESSAGE = "Are you sure you want to restore the default settings?";
  static const RESTORE = 'Restore';
  static const WORKSHEET_TITLES = "Worksheet Titles";
  static const TYPES_MASTER_COLUMNS = "Types: Master Columns";
  static const TYPES_DESTINATION_COLUMNS = "Types: Destination Columns";
  static const BALANCES_TABLE = "Balances Table";
  static const FROM_ROW = "From Row";
  static const FROM_COLUMN = "From Column";
  static const COLUMNS_LENGTH = "Columns Length";
  static const DEBTS_TABLE = "Debts Table";
  static const START_ROWS = "Start Rows";
}
