import 'package:flutter/material.dart';


/* 
  ┌──────────────────────────────────────────────────────────────────────────┐
  │                Implementing Custom Route Transitions                     │
  └──────────────────────────────────────────────────────────────────────────┘
   https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/learn/lecture/15157140#overview
   https://github.com/devopsengineering06/flutter_myshop_app/commit/c8e198a9b0fbd44c251a8d37d08746ad285fe636
*/

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
     required WidgetBuilder builder,
     RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
 @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}