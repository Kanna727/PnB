import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:portfolio_n_budget/constants.dart';
import 'package:portfolio_n_budget/widgets/searchWidget.dart';

class FrostedAppBar extends StatefulWidget {
  //
  double? height;
  Widget? leading;
  List<Widget>? actions;
  List lines;
  Color? color;
  double? blurStrengthX;
  double? blurStrengthY;
  bool showSearchBar = false;
  String searchQuery;
  var onSearch;
  var searchBarFocusNode;
  //constructor
  FrostedAppBar({
    this.height,
    this.actions,
    required this.lines,
    this.blurStrengthX,
    this.blurStrengthY,
    this.color,
    this.leading,
    required this.showSearchBar,
    required this.searchQuery,
    required this.onSearch,
    required this.searchBarFocusNode,
  });
  //
  @override
  _FrostedAppBarState createState() => _FrostedAppBarState();
}

class _FrostedAppBarState extends State<FrostedAppBar> {
  @override
  Widget build(BuildContext context) {
    var scrSize = MediaQuery.of(context).size;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurStrengthX ?? 10,
          sigmaY: widget.blurStrengthY ?? 10,
        ),
        child: Container(
          alignment: Alignment.center,
          width: scrSize.width,
          height: widget.height ?? 65,
          child: Padding(
            padding: new EdgeInsets.symmetric(vertical: 2),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 15),
                        width: 56,
                        color: Colors.transparent,
                        child: widget.leading,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.lines.length == 0
                                ? "Balances Loading..."
                                : widget.lines[0][0] +
                                    " : " +
                                    getCurrencyFormat(widget.lines[0][1]),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      Row(
                        children: widget.actions ??
                            [
                              Container(
                                width: 50,
                              )
                            ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.showSearchBar,
                  child: SearchWidget(
                    text: widget.searchQuery,
                    hintText: 'Search',
                    onChanged: widget.onSearch,
                    focusNode: widget.searchBarFocusNode,
                  ),
                ),
                ...widget.lines
                    .skip(1)
                    .map((e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                e[0],
                                style: TextStyle(fontSize: 15),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Text(
                                getCurrencyFormat(e[1]),
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    ); // to clip the container;
  }
}
