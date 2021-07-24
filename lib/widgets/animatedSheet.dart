import 'package:flutter/material.dart';

class AnimatedSheet extends StatefulWidget {
  AnimatedSheet({
    Key? key,
    required this.offset,
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    required this.backgroundColor,
    this.onHeightChange,
  }) : super(key: key);

  var offset;
  var child;
  var onHeightChange;
  final minHeight;
  final maxHeight;
  final backgroundColor;

  @override
  _AnimatedSheetState createState() => _AnimatedSheetState();
}

class _AnimatedSheetState extends State<AnimatedSheet> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        widget.offset = Offset(0, widget.offset.dy - details.delta.dy);
        if (widget.offset.dy < widget.minHeight) {
          widget.offset = Offset(0, widget.minHeight);
        } else if (widget.offset.dy > widget.maxHeight) {
          widget.offset = Offset(0, widget.maxHeight);
        }
        if (widget.onHeightChange != null) {
          widget.onHeightChange(widget.offset);
        }
      },
      onPanEnd: (details) {
        if (widget.offset.dy < (widget.maxHeight - widget.minHeight) * 0.75) {
          widget.offset = Offset(0, widget.minHeight);
        } else if (widget.offset.dy >
            (widget.maxHeight - widget.minHeight) * 0.25) {
          widget.offset = Offset(0, widget.maxHeight);
        }
      },
      child: AnimatedContainer(
        duration: Duration.zero,
        curve: Curves.easeOut,
        height: widget.offset.dy,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: ThemeData.dark().backgroundColor,
          color: widget.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
