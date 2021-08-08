import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:portfolio_n_budget/constants.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;
  final focusNode;

  const SearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
    this.focusNode,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: Colors.white);
    final styleHint = TextStyle(color: Colors.white54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      // height: SEARCH_WIDGET_HEIGHT,
      // margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        // border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          // icon: Icon(Icons.search, color: style.color),
          // suffixIcon: widget.text.isNotEmpty
          //     ? GestureDetector(
          //         child: Icon(Icons.close, color: style.color),
          //         onTap: () {
          //           controller.clear();
          //           widget.onChanged('');
          //           FocusScope.of(context).requestFocus(FocusNode());
          //         },
          //       )
          //     : null,
          hintText: widget.hintText,
          hintStyle: style,
          border: InputBorder.none,
        ),
        style: style,
        onChanged: widget.onChanged,
      ),
    );
  }
}
