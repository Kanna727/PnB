import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/transactions/add.dart';
import 'pages/balances/overview.dart';
import 'widgets/frostedBottomNavBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // to hide the status bar
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Portfolio & Budget',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  var _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    BalancesOverview(),
    Padding(
      padding: EdgeInsets.only(bottom: 65),
      child: AddTransaction(),
    ),
  ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //     _pageController.animateToPage(_selectedIndex,
  //         duration: Duration(milliseconds: 200), curve: Curves.linear);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _widgetOptions.elementAt(_selectedIndex),
          // PageView(
          //   //scrollDirection: Axis.vertical,
          //   children: _widgetOptions,
          //   onPageChanged: (index) {
          //     setState(() {
          //       _selectedIndex = index;
          //     });
          //   },
          //   controller: _pageController,
          // ),
          // FrostedBottomNavBar(
          //     bottomNavigationBarItems: const <BottomNavigationBarItem>[
          //       BottomNavigationBarItem(
          //           icon: Icon(Icons.account_balance), label: 'Balances'),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.receipt),
          //         label: 'Trasanctions',
          //       ),
          //     ],
          //     currentIndex: _selectedIndex,
          //     onIndexChange: (val) {
          //       _onItemTapped(val);
          //     }),
        ],
      ),
    );
  }
}
