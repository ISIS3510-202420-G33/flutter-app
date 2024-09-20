import 'package:flutter/material.dart';
import 'package:artlens/views/artwork_view.dart';
import 'package:artlens/views/home_view.dart';

class Routes {
  static const String home = '/';
  static const String artwork = '/artwork';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeView());
      //case artwork:
      //  return MaterialPageRoute(builder: (_) => ArtworkView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
