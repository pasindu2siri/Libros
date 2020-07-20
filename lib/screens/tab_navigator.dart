import 'package:flutter/material.dart';
import 'package:Libros/pages/home.dart';
import 'package:Libros/pages/profile.dart';
import 'package:Libros/pages/explore.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (tabItem == "Home")
      child = HomePage();
    else if (tabItem == "Explore")
      child = ExplorePage();
    else if (tabItem == "Profile") child = ProfilePage();

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
