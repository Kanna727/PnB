import 'package:flutter/material.dart';

class FAB extends StatelessWidget {
  const FAB(
      {Key? key,
      // required this.enabled,
      // required this.onPressed,
      // required this.toolTip,
      // required this.icon,
      // this.expanded = false,
      // this.expandedText = "Click Here"
      })
      : super(key: key);
  // final onPressed;
  // final toolTip;
  // final enabled;
  // final expanded;
  // final expandedText;
  // final icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      // tooltip: toolTip,
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
        child: true
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.add),
              )
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.add),
                  ),
                  Text("expandedText")
                ],
              ),
      ),
      backgroundColor: !true ? Colors.grey : null,
    );
  }
}
