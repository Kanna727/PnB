import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:portfolio_n_budget/api/gsheets.dart';
import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/utils/credentials_secure_storage.dart';
import 'package:portfolio_n_budget/widgets/searchWidget.dart';

import 'row.dart';
import 'package:portfolio_n_budget/pages/transactions/add.dart';
import 'package:portfolio_n_budget/widgets/frostedAppBar.dart';
import 'package:portfolio_n_budget/widgets/spinningIconButton.dart';

bool isLoading = true;
bool isSyncing = true;
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
  late final AnimationController _syncController =
      AnimationController(duration: const Duration(seconds: 1), vsync: this);
  late final Animation<double> _syncAnimation =
      CurvedAnimation(parent: _syncController, curve: Curves.fastOutSlowIn);
  late final AnimationController _searchController =
      AnimationController(duration: const Duration(seconds: 1), vsync: this);
  late final Animation<double> _searchAnimation =
      CurvedAnimation(parent: _searchController, curve: Curves.fastOutSlowIn);
  final _scrollController = ScrollController();
  double _appBarHeight = 65;
  String query = '';
  var rows = [];
  var filteredRows = [];
  var totals = [];
  var filteredTotal = [];
  bool _showSearchBar = false;
  var _searchBoxFocusNode = FocusNode();

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
    _syncController.dispose();
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
      isSyncing ? _syncController.forward() : _syncController.reverse();
      _fabController.reverse();
    } else {
      _syncController.forward();
      _fabController.forward();
    }
  }

  Future<void> _getData() async {
    setState(() {
      isSyncing = true;
    });
    _syncController.forward();
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
      isSyncing = false;
      rows = fetchedRows;
      totals = totalsCols;
    });
    searchAccounts(query);
    _rotateController.forward(from: _rotateController.value);
    _syncController.reverse();
    _searchController.forward();
  }

  bool expanded = false;

  static double _minHeight = kToolbarHeight,
      _minAppBarHeight = kToolbarHeight,
      _maxHeight = 1000,
      _maxAppBarHeight = EXPANDED_APP_BAR_HEIGHT;
  Offset _offset = Offset(0, _minHeight);
  Offset _appBarOffset = Offset(0, _minAppBarHeight);
  Offset _searchOffset = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    _maxHeight = MediaQuery.of(context).size.height - EXPANDED_APP_BAR_HEIGHT;
    _minAppBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    if(_appBarOffset.dy == kToolbarHeight) _appBarOffset = Offset(0, _minAppBarHeight);
    _maxAppBarHeight = _showSearchBar
        ? _minHeight + SEARCH_WIDGET_HEIGHT
        : query == ''
            ? EXPANDED_APP_BAR_HEIGHT
            : _minHeight;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          isLoading
              ? Center(child: LinearProgressIndicator())
              : RefreshIndicator(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredRows.length,
                      itemBuilder: (context, index) =>
                          (filteredRows[index][0] == filteredRows.first[0])
                              ? Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.fastOutSlowIn,
                                      height: _searchOffset.dy,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: kToolbarHeight),
                                      child: BalanceRow(filteredRows[index]),
                                    )
                                  ],
                                )
                              : (filteredRows[index][0] == filteredRows.last[0])
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: kToolbarHeight),
                                      child: BalanceRow(filteredRows[index]),
                                    )
                                  : BalanceRow(filteredRows[index])),
                  onRefresh: _getData),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
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
                      _scrollController.position.pixels == 0)) {
                    _syncController.forward();
                    _fabController.forward();
                  }
                } else if (_offset.dy > (_maxHeight - _minHeight) * 0.25) {
                  _offset = Offset(0, _maxHeight);
                  if (!(_scrollController.position.atEdge &&
                      _scrollController.position.pixels == 0)) {
                    _fabController.reverse();
                    isSyncing
                        ? _syncController.forward()
                        : _syncController.reverse();
                  }
                }
                setState(() {});
              },
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    height: _offset.dy,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: AddTransaction(
                        showFAB: _offset.dy > kToolbarHeight * 3,
                        postAddTrasnactionCallback: _getData),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onPanUpdate: (details) {
                _appBarOffset = Offset(0, _appBarOffset.dy + details.delta.dy);
                if (_appBarOffset.dy < _minAppBarHeight) {
                  _appBarOffset = Offset(0, _minAppBarHeight);
                } else if (_appBarOffset.dy > _maxAppBarHeight) {
                  _appBarOffset = Offset(0, _maxAppBarHeight);
                }
                setState(() {});
              },
              onPanEnd: (details) {
                if (_appBarOffset.dy <
                    (EXPANDED_APP_BAR_HEIGHT - _minAppBarHeight) * 0.75) {
                  _appBarOffset = Offset(0, _minAppBarHeight);
                  _showSearchBar = false;
                  _searchOffset = Offset(0, 0);
                  _searchController.forward();
                } else if (_appBarOffset.dy >
                    (EXPANDED_APP_BAR_HEIGHT - _minAppBarHeight) * 0.25) {
                  _appBarOffset = Offset(0, EXPANDED_APP_BAR_HEIGHT);
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
                  lines: filteredTotal,
                  height: _appBarOffset.dy,
                  searchQuery: query,
                  onSearch: searchAccounts,
                  showSearchBar: _showSearchBar,
                  searchBarFocusNode: _searchBoxFocusNode,
                  actions: [
                    ScaleTransition(
                      scale: _syncAnimation,
                      child: SpinningIconButton(
                          controller: _rotateController,
                          iconData: Icons.sync,
                          onPressed: _getData),
                    ),
                    ScaleTransition(
                      scale: _searchAnimation,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _showSearchBar = true;
                              _searchController.reverse();
                              _searchOffset = Offset(
                                  0,
                                  SEARCH_WIDGET_HEIGHT +
                                      ACCOUNT_CARDS_VERTICAL_MARGIN);
                              _appBarOffset = Offset(
                                  0, _minAppBarHeight + SEARCH_WIDGET_HEIGHT);
                            });
                            _searchBoxFocusNode.requestFocus();
                          },
                          icon: Icon(Icons.search)),
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

  void searchAccounts(String query) {
    num total = 0;
    final filteredRows = rows.where((row) {
      final titleLower = row[0].toLowerCase();
      final searchLower = query.toLowerCase();

      var contains = titleLower.contains(searchLower);
      if (contains) total += double.parse(row[2]);
      return contains;
    }).toList();

    setState(() {
      this.query = query;
      this.filteredRows = filteredRows;
      this.filteredTotal = query != ''
          ? [
              ["Total", "$total"]
            ]
          : totals;
    });
  }
}
