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
  // "Savings",
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
  "Self Transfer": 32,
  "Reward Points": 40,
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
  static const PERMISSION_ERROR = "You do not have enough permissions to perform this action";
}
