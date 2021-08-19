import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedDrawer extends StatelessWidget {
  double? width;
  Widget? child;
  FrostedDrawer({
    this.width,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: this.width ?? MediaQuery.of(context).size.width * 0.4,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: Drawer(
          elevation: 0,
          child: ClipPath(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(),
                ),
                this.child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
