import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedBottomNavBar extends StatefulWidget {
  //
  double? height;
  Widget? title;
  Widget? leading;
  List<Widget>? actions;
  Color? color;
  double? blurStrengthX;
  double? blurStrengthY;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final Color backgroundColor;
  final BottomNavigationBarType bottomNavigationBarType;
  final int currentIndex;
  final List<BottomNavigationBarItem> bottomNavigationBarItems;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Function(int) onIndexChange;
  //constructor
  FrostedBottomNavBar(
      {this.height,
      this.actions,
      this.blurStrengthX,
      this.blurStrengthY,
      this.color,
      this.leading,
      this.title,
      this.showSelectedLabels = false,
      this.showUnselectedLabels = false,
      this.backgroundColor = Colors.transparent,
      this.bottomNavigationBarType = BottomNavigationBarType.fixed,
      this.currentIndex = 0,
      required this.onIndexChange,
      required this.bottomNavigationBarItems,
      this.selectedItemColor = Colors.blue,
      this.unselectedItemColor = Colors.white});
  //
  @override
  _FrostedBottomNavBarState createState() => _FrostedBottomNavBarState();
}

class _FrostedBottomNavBarState extends State<FrostedBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            // will be 10 by default if not provided
            sigmaX: widget.blurStrengthX ?? 10,
            sigmaY: widget.blurStrengthY ?? 10,
          ),
          child: BottomNavigationBar(
            elevation: 0,
            showSelectedLabels: widget.showSelectedLabels,
            showUnselectedLabels: widget.showUnselectedLabels,
            backgroundColor: widget.backgroundColor,
            type: widget.bottomNavigationBarType,
            items: widget.bottomNavigationBarItems,
            currentIndex: widget.currentIndex,
            selectedItemColor: widget.selectedItemColor,
            unselectedItemColor: widget.unselectedItemColor,
            onTap: (index) {
              widget.onIndexChange(index);
            },
          ),
        ),
      ), // to clip the container
    );
  }
}
