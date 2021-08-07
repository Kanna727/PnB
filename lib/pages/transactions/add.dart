import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_n_budget/api/gsheets.dart';

import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';
import 'package:portfolio_n_budget/widgets/datePicker.dart';
import 'package:portfolio_n_budget/widgets/dropdown.dart';

bool isLoading = true,
    isSaving = false,
    itemsFetched = true,
    isRefreshing = false;
var type;
var item;
var debitAccount;
var creditAccount;
var date;
bool toBeCredited = false;
bool toBeDebited = false;
late Spreadsheet spreadsheet;
late Worksheet transactionsSheet;
late Worksheet assetManagementSheet;
late Worksheet debtsSheet;
var names;
var items;

final _formKey = GlobalKey<FormState>();

TextEditingController _amountController = TextEditingController();
TextEditingController _noteController = TextEditingController();

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key, this.showFAB = false}) : super(key: key);

  final showFAB;

  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _getData() async {
    var credentials = await CredentialsSecureStorage.getCredentials();
    var sheetID = await CredentialsSecureStorage.getSheetID();

    final gsheets = GSheets(credentials);
    spreadsheet = await gsheets.spreadsheet(sheetID!);

    transactionsSheet =
        spreadsheet.worksheetByTitle(WORKSHEET_TITLES.TRANSACTIONS);
    assetManagementSheet =
        spreadsheet.worksheetByTitle(WORKSHEET_TITLES.ASSET_MANAGEMENT);

    var fetchedNames = await assetManagementSheet.values
        .column(BALANCES_TABLE.fromColumn, fromRow: BALANCES_TABLE.fromRow);

    setState(() {
      isLoading = false;
      names = fetchedNames;
      date = DateFormat(DATE_FORMAT).format(DateTime.now());
    });
  }

  Future<void> _getItems(String type) async {
    var typeMasterColumn = TYPES_MASTER_COLUMNS[type];
    if (typeMasterColumn == null) {
      return;
    }
    var fetchedItems;
    if (type == TYPES_CLASS.LIABILITY) {
      setState(() {
        itemsFetched = false;
      });
      debtsSheet = spreadsheet.worksheetByTitle(WORKSHEET_TITLES.DEBTS);
      fetchedItems = await debtsSheet.values
          .column(TYPES_MASTER_COLUMNS[type]!, fromRow: DEBTS_TABLE.fromRow);
    } else {
      setState(() {
        itemsFetched = false;
      });
      fetchedItems = await assetManagementSheet.values
          .column(typeMasterColumn, fromRow: ASSET_MANAGEMENT_SHEET_START_ROW);
    }

    if (fetchedItems != null) {
      setState(() {
        items = fetchedItems;
        itemsFetched = true;
      });
    }
  }

  Future<void> onRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    await _getData();
    if (type != null) await _getItems(type);
    setState(() {
      isRefreshing = false;
    });
  }

  void onTypeChange(String? newValue) {
    setState(() {
      type = newValue!;
      item = null;
      debitAccount = null;
      creditAccount = null;
    });
    _getItems(newValue!);
  }

  void onItemChange(String? newValue) {
    setState(() {
      item = newValue!;
    });
  }

  void onDebitAccountChange(String? newValue) {
    setState(() {
      debitAccount = newValue!;
    });
  }

  void onCreditAccountChange(String? newValue) {
    setState(() {
      creditAccount = newValue!;
    });
  }

  void onDateChange(String? newValue) {
    setState(() {
      date = newValue;
    });
  }

  void onAmountChange(String newValue) {
    setState(() {
      _amountController.text = NumberFormat.currency(
              locale: LOCALE, symbol: CURRENCY_SYMBOL_WITH_SPACE)
          .parse(newValue)
          .toString();
    });
  }

  void onNoteChange(String newValue) {
    setState(() {
      _noteController.text = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isNotFilled = type == null ||
        (!(type == TYPES_CLASS.SAVINGS || type == TYPES_CLASS.REWARD_POINTS) &&
            item == null) ||
        (!(type == TYPES_CLASS.INCOME || type == TYPES_CLASS.REWARD_POINTS) &&
            debitAccount == null) ||
        (!(type == TYPES_CLASS.EXPENSE || type == TYPES_CLASS.LIABILITY) &&
            creditAccount == null) ||
        _amountController.text.isEmpty ||
        (!(type == TYPES_CLASS.LIABILITY || type == TYPES_CLASS.SAVINGS) &&
            _noteController.text.isEmpty);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Container(
              height: 5,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(UI_TEXTS.ADD_TRANSACTION),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Visibility(
              visible: widget.showFAB && !isLoading && !isRefreshing,
              child:
                  IconButton(onPressed: onRefresh, icon: Icon(Icons.refresh)))
        ],
      ),
      body: Center(
        child: isLoading
            ? Container()
            : isRefreshing
                ? CircularProgressIndicator()
                : Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dropdown(
                            dropdownValue: type,
                            onChange: onTypeChange,
                            list: isSaving ? null : TYPES,
                            title: UI_TEXTS.TYPE,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return UI_TEXTS.TYPE_ERROR;
                              }
                              return null;
                            },
                          ),
                        ),
                        Visibility(
                          visible: !(type == TYPES_CLASS.SELF_TRANSFER ||
                              type == TYPES_CLASS.REWARD_POINTS),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Dropdown(
                              dropdownValue: item,
                              onChange: onItemChange,
                              list: isSaving || !itemsFetched ? null : items,
                              title: UI_TEXTS.ITEM,
                              validator: (value) {
                                if (type == TYPES_CLASS.SELF_TRANSFER)
                                  return null;
                                if (value == null || value.isEmpty) {
                                  return UI_TEXTS.ITEM_ERROR;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !(type == TYPES_CLASS.INCOME ||
                              type == TYPES_CLASS.REWARD_POINTS),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Dropdown(
                              dropdownValue: debitAccount,
                              onChange: onDebitAccountChange,
                              list: isSaving ? null : names,
                              title: UI_TEXTS.DEBIT_ACCOUNT,
                              validator: (value) {
                                if (type == TYPES_CLASS.INCOME) return null;
                                if (value == null || value.isEmpty) {
                                  return UI_TEXTS.DEBIT_ACCOUNT_ERROR;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: type == TYPES_CLASS.INCOME ||
                              type == TYPES_CLASS.SAVINGS ||
                              type == TYPES_CLASS.SELF_TRANSFER ||
                              type == TYPES_CLASS.REWARD_POINTS,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Dropdown(
                              dropdownValue: creditAccount,
                              onChange: onCreditAccountChange,
                              list: isSaving ? null : names,
                              title: UI_TEXTS.CREDIT_ACCOUNT,
                              validator: (value) {
                                if (type == TYPES_CLASS.EXPENSE ||
                                    type == TYPES_CLASS.LIABILITY) return null;
                                if (value == null || value.isEmpty) {
                                  return UI_TEXTS.CREDIT_ACCOUNT_ERROR;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DateTimePicker(
                            date: date,
                            onChange: onDateChange,
                            title: UI_TEXTS.DATE,
                            disabled: isSaving,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: !isSaving,
                            inputFormatters: type == TYPES_CLASS.REWARD_POINTS
                                ? null
                                : [
                                    CurrencyTextInputFormatter(
                                        locale: LOCALE,
                                        symbol: CURRENCY_SYMBOL_WITH_SPACE)
                                  ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: type == TYPES_CLASS.REWARD_POINTS
                                  ? UI_TEXTS.POINTS
                                  : UI_TEXTS.AMOUNT,
                            ),
                            onChanged: onAmountChange,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return type == TYPES_CLASS.REWARD_POINTS
                                    ? UI_TEXTS.POINTS_ERROR
                                    : UI_TEXTS.AMOUNT_ERROR;
                              }
                              return null;
                            },
                            onEditingComplete: () =>
                                FocusScope.of(context).nextFocus(),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        Visibility(
                          visible: !(type == TYPES_CLASS.LIABILITY ||
                              type == TYPES_CLASS.SAVINGS),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: !isSaving,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: UI_TEXTS.NOTE,
                              ),
                              onChanged: onNoteChange,
                              validator: (value) {
                                if (type == TYPES_CLASS.LIABILITY ||
                                    type == TYPES_CLASS.SAVINGS) return null;
                                if (value == null || value.isEmpty) {
                                  return UI_TEXTS.NOTE_ERROR;
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: !(type == TYPES_CLASS.INCOME ||
                                type == TYPES_CLASS.REWARD_POINTS),
                            child: CheckboxListTile(
                              title: Text("To be debited"),
                              value: toBeDebited,
                              onChanged: (newValue) {
                                setState(() {
                                  toBeDebited = newValue!;
                                });
                              },
                            )),
                        Visibility(
                            visible: !(type == TYPES_CLASS.EXPENSE),
                            child: CheckboxListTile(
                              title: Text("To be credited"),
                              value: toBeCredited,
                              onChanged: (newValue) {
                                setState(() {
                                  toBeCredited = newValue!;
                                });
                              },
                            )),
                      ],
                    )),
      ),
      floatingActionButton: Visibility(
        visible: widget.showFAB,
        child: FloatingActionButton.extended(
          onPressed: onSave,
          tooltip: UI_TEXTS.ADD_TRANSACTION,
          label: AnimatedSwitcher(
            duration: Duration(seconds: 1),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(
              opacity: animation,
              child: SizeTransition(
                child: child,
                sizeFactor: animation,
                axis: Axis.horizontal,
              ),
            ),
            child: isLoading || isNotFilled || isSaving || isRefreshing
                ? Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: isSaving
                        ? CircularProgressIndicator(
                            color: ColorScheme.dark().primary,
                          )
                        : Icon(Icons.save),
                  )
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(Icons.save),
                      ),
                      Text("Save")
                    ],
                  ),
          ),
          backgroundColor:
              isLoading || isNotFilled || isRefreshing ? Colors.grey : null,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void onSave() async {
    if (isLoading || isRefreshing) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSaving = true;
      });
      var destColIndex = TYPES_DESTINATION_COLUMNS[type]!;
      var destinationCol = await transactionsSheet.values
          .column(destColIndex, fromRow: TRANSACTIONS_START_ROW);

      var data = [];
      if (type == TYPES_CLASS.INCOME) {
        data = [
          item,
          _amountController.text,
          date,
          creditAccount,
          _noteController.text,
          toBeCredited,
        ];
      } else if (type == TYPES_CLASS.EXPENSE) {
        data = [
          item,
          _amountController.text,
          date,
          debitAccount,
          _noteController.text,
          toBeDebited,
        ];
      } else if (type == TYPES_CLASS.LIABILITY) {
        data = [
          item,
          _amountController.text,
          date,
          debitAccount,
          toBeDebited,
          toBeCredited
        ];
      } else if (type == TYPES_CLASS.SAVINGS) {
        data = [
          item,
          _amountController.text,
          date,
          debitAccount,
          creditAccount
        ];
      } else if (type == TYPES_CLASS.SELF_TRANSFER) {
        data = [
          _amountController.text,
          date,
          debitAccount,
          creditAccount,
          _noteController.text,
          toBeDebited,
          toBeCredited,
        ];
      } else if (type == TYPES_CLASS.REWARD_POINTS) {
        data = [
          _amountController.text,
          date,
          creditAccount,
          _noteController.text,
          toBeCredited,
        ];
      }

      await transactionsSheet.values
          .insertRow(destinationCol.length + 3, data, fromColumn: destColIndex);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(UI_TEXTS.TRANSACTION_SAVED)));

      setState(() {
        isSaving = false;
      });
    }
  }
}
