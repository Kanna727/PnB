import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:portfolio_n_budget/api/gsheets.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';

import 'row.dart';
import 'package:portfolio_n_budget/pages/transactions/add.dart';
import 'package:portfolio_n_budget/widgets/forstedAppBar.dart';
import 'package:portfolio_n_budget/widgets/spinningIconButton.dart';

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
    with TickerProviderStateMixin {
  late final AnimationController _rotateController =
      AnimationController(duration: Duration(seconds: 1), vsync: this);
  late final AnimationController _fabController =
      AnimationController(duration: const Duration(seconds: 1), vsync: this);
  late final Animation<double> _fabAnimation =
      CurvedAnimation(parent: _fabController, curve: Curves.fastOutSlowIn);
  final _scrollController = ScrollController();
  double _appBarHeight = 65;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(listenScrolling);
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
    _rotateController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void listenScrolling() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels == 0) {
      _fabController.reverse();
    } else {
      _fabController.forward();
    }
  }

  Future<void> _getData() async {
    _rotateController.repeat();
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
    _rotateController.forward(from: _rotateController.value);
  }

  bool expanded = false;

  static double _minHeight = kToolbarHeight,
      _maxHeight = 1000,
      _maxAppBarHeight = EXPANDED_APP_BAR_HEIGHT;
  Offset _offset = Offset(0, _minHeight);
  Offset _appBarOffset = Offset(0, _minHeight);
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
                          child: ListView.builder(
                              controller: _scrollController,
                              itemBuilder: (context, index) =>
                                  (rows[index][0] == rows.first[0])
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: kToolbarHeight),
                                          child: BalanceRow(rows[index]),
                                        )
                                      : (rows[index][0] == rows.last[0])
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: kToolbarHeight),
                                              child: BalanceRow(rows[index]),
                                            )
                                          : BalanceRow(rows[index])),
                          onRefresh: _getData))),
          GestureDetector(
            onPanUpdate: (details) {
              _offset = Offset(0, _offset.dy - details.delta.dy);
              if (_offset.dy < _minHeight) {
                _offset = Offset(0, _minHeight);
              } else if (_offset.dy > _maxHeight) {
                _offset = Offset(0, _maxHeight);
              }
              setState(() {});
            },
            onPanEnd: (details) {
              if (_offset.dy < (_maxHeight - _minHeight) * 0.75) {
                _offset = Offset(0, _minHeight);
                if (!(_scrollController.position.atEdge &&
                    _scrollController.position.pixels == 0))
                  _fabController.forward();
              } else if (_offset.dy > (_maxHeight - _minHeight) * 0.25) {
                _offset = Offset(0, _maxHeight);
                if (!(_scrollController.position.atEdge &&
                    _scrollController.position.pixels == 0))
                  _fabController.reverse();
              }
              setState(() {});
            },
            child: AnimatedContainer(
              duration: Duration.zero,
              curve: Curves.easeOut,
              height: _offset.dy,
              alignment: Alignment.center,
              decoration: BoxDecoration(
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
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: FrostedAppBar(
                  lines: totals,
                  height: _appBarOffset.dy,
                  actions: [
                    ScaleTransition(
                      scale: _fabAnimation,
                      child: SpinningIconButton(
                          controller: _rotateController,
                          iconData: Icons.sync,
                          onPressed: _getData),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          child: Icon(
            Icons.keyboard_arrow_up,
            size: 35,
          ),
          onPressed: scrollUp,
        ),
      ),
    );
  }

  void scrollUp() {
    final double start = 0;

    _scrollController.animateTo(start,
        duration: Duration(seconds: 1), curve: Curves.easeIn);
  }
}
