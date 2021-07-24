import 'package:flutter/material.dart';
import 'package:portfolio_n_budget/constants.dart';

class ExpandingToolBar extends StatefulWidget {
  const ExpandingToolBar({Key? key}) : super(key: key);

  @override
  _ExpandingToolBarState createState() => _ExpandingToolBarState();
}

class _ExpandingToolBarState extends State<ExpandingToolBar> {
  static double _minHeight = kToolbarHeight, _maxHeight = 1000;

  Offset _offset = Offset(0, _minHeight);

  Offset _appBarOffset = Offset(0, _minHeight);

  bool _isOpen = false;

  bool _isAppBarOpen = false;

  @override
  Widget build(BuildContext context) {
    _maxHeight = MediaQuery.of(context).size.height - EXPANDED_APP_BAR_HEIGHT;
    return GestureDetector(
      onPanUpdate: (details) {
        _offset = Offset(0, _offset.dy - details.delta.dy);
        if (_offset.dy < _ExpandingToolBarState._minHeight) {
          _offset = Offset(0, _ExpandingToolBarState._minHeight);
          _isOpen = false;
        } else if (_offset.dy > _ExpandingToolBarState._maxHeight) {
          _offset = Offset(0, _ExpandingToolBarState._maxHeight);
          _isOpen = true;
        }
        setState(() {});
      },
      onPanEnd: (details) {
        if (_offset.dy <
            (_ExpandingToolBarState._maxHeight -
                    _ExpandingToolBarState._minHeight) *
                0.75) {
          _offset = Offset(0, _ExpandingToolBarState._minHeight);
          _isOpen = false;
        } else if (_offset.dy >
            (_ExpandingToolBarState._maxHeight -
                    _ExpandingToolBarState._minHeight) *
                0.25) {
          _offset = Offset(0, _ExpandingToolBarState._maxHeight);
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
        child: Text("Hello"),
      ),
    );
  }
}
