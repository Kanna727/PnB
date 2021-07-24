import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:portfolio_n_budget/api/gsheets.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/credentials.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';
import 'package:portfolio_n_budget/widgets/forstedAppBar.dart';

import 'row.dart';
import 'package:portfolio_n_budget/pages/transactions/add.dart';

bool isLoading = true;
var rows = [];
var totals = [];
late Spreadsheet spreadsheet;
late Worksheet assetManagementSheet;

class BalancesOverview extends StatefulWidget {
  const BalancesOverview({Key? key}) : super(key: key);

  @override
  _BalancesOverviewState createState() => _BalancesOverviewState();
}

class _BalancesOverviewState extends State<BalancesOverview>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  static final _sizeTween =
      new Tween<double>(begin: 0.0, end: EXPANDED_APP_BAR_HEIGHT);
  double appBarHeight = 65;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new AnimationController(
        duration: new Duration(milliseconds: 2500), vsync: this);
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

    assetManagementSheet =
        spreadsheet.worksheetByTitle(WORKSHEET_TITLES.ASSET_MANAGEMENT);

    var fetchedRows = await assetManagementSheet.values.allRows(
        fromRow: BALANCES_TABLE.fromRow,
        length: BALANCES_TABLE.columnsLength,
        fill: true);

    var totalsCols = await assetManagementSheet.values.allRows(
        fromRow: TOTALS_TABLE.fromRow,
        fromColumn: TOTALS_TABLE.fromColumn,
        length: TOTALS_TABLE.columnsLength);

    fetchedRows.removeWhere((element) => element[0] == SALARY_DEDUCTION);

    setState(() {
      isLoading = false;
      rows = fetchedRows;
      totals = totalsCols;
    });
  }

  bool expanded = false;

  _animateAppBar() {
    setState(() {
      expanded ? controller.reverse() : controller.forward();
      expanded = !expanded;
    });
  }

  static double _minHeight = kToolbarHeight,
      _maxHeight = 1000,
      _maxAppBarHeight = EXPANDED_APP_BAR_HEIGHT;
  Offset _offset = Offset(0, _minHeight);
  Offset _appBarOffset = Offset(0, _minHeight);
  bool _isOpen = false;
  bool _isAppBarOpen = false;

  @override
  Widget build(BuildContext context) {
    _maxHeight = MediaQuery.of(context).size.height - EXPANDED_APP_BAR_HEIGHT;
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Align(
              child: Center(
                  child: isLoading
                      ? LinearProgressIndicator()
                      : RefreshIndicator(
                          child: ListView(
                              children: rows
                                  .map((e) => (e[0] == rows.first[0])
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: kToolbarHeight),
                                          child: BalanceRow(e),
                                        )
                                      : (e[0] == rows.last[0])
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: kToolbarHeight),
                                              child: BalanceRow(e),
                                            )
                                          : BalanceRow(e))
                                  .toList()),
                          onRefresh: _getData))),
          GestureDetector(
            onPanUpdate: (details) {
              _offset = Offset(0, _offset.dy - details.delta.dy);
              if (_offset.dy < _minHeight) {
                _offset = Offset(0, _minHeight);
                _isOpen = false;
              } else if (_offset.dy > _maxHeight) {
                _offset = Offset(0, _maxHeight);
                _isOpen = true;
              }
              setState(() {});
            },
            onPanEnd: (details) {
              if (_offset.dy < (_maxHeight - _minHeight) * 0.75) {
                _offset = Offset(0, _minHeight);
                _isOpen = false;
              } else if (_offset.dy > (_maxHeight - _minHeight) * 0.25) {
                _offset = Offset(0, _maxHeight);
                _isOpen = true;
              }
              setState(() {});
            },
            child: AnimatedContainer(
              duration: Duration.zero,
              curve: Curves.easeOut,
              height: _offset.dy,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // color: ThemeData.dark().backgroundColor,
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: AddTransaction(
                showFAB: _offset.dy > kToolbarHeight * 3,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onPanUpdate: (details) {
                _appBarOffset = Offset(0, _appBarOffset.dy + details.delta.dy);
                if (_appBarOffset.dy < _minHeight) {
                  _appBarOffset = Offset(0, _minHeight);
                  _isAppBarOpen = false;
                } else if (_appBarOffset.dy > _maxAppBarHeight) {
                  _appBarOffset = Offset(0, _maxAppBarHeight);
                  _isAppBarOpen = true;
                }
                setState(() {});
              },
              onPanEnd: (details) {
                if (_appBarOffset.dy < (_maxAppBarHeight - _minHeight) * 0.75) {
                  _appBarOffset = Offset(0, _minHeight);
                  _isAppBarOpen = false;
                } else if (_appBarOffset.dy >
                    (_maxAppBarHeight - _minHeight) * 0.25) {
                  _appBarOffset = Offset(0, _maxAppBarHeight);
                  _isAppBarOpen = true;
                }
                setState(() {});
              },
              child: AnimatedContainer(
                duration: Duration.zero,
                curve: Curves.easeOut,
                height: _appBarOffset.dy,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // color: ThemeData.dark().backgroundColor,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: FrostedAppBar(
                  lines: totals,
                  height: _appBarOffset.dy,
                ),
              ),
            ),
          ),
          // Positioned(
          //   bottom: 2 * _minHeight -
          //       _offset.dy -
          //       28, // 56 is the height of FAB so we use here half of it.
          //   child: FloatingActionButton(
          //     child: Icon(_isOpen ? Icons.keyboard_arrow_down : Icons.add),
          //     onPressed: _handleClick,
          //   ),
          // ),
        ],
      ),
    );
  }

  // first it opens the sheet and when called again it closes.
  void _handleClick() {
    _isOpen = !_isOpen;
    Timer.periodic(Duration(milliseconds: 5), (timer) {
      if (_isOpen) {
        double value = _offset.dy +
            10; // we increment the height of the Container by 10 every 5ms
        _offset = Offset(0, value);
        if (_offset.dy > _maxHeight) {
          _offset =
              Offset(0, _maxHeight); // makes sure it does't go above maxHeight
          timer.cancel();
        }
      } else {
        double value = _offset.dy - 10; // we decrement the height by 10 here
        _offset = Offset(0, value);
        if (_offset.dy < _minHeight) {
          _offset = Offset(
              0, _minHeight); // makes sure it doesn't go beyond minHeight
          timer.cancel();
        }
      }
      setState(() {});
    });
  }
}
