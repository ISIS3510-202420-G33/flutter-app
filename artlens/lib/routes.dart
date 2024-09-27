// /lib/routes.dart
import 'package:flutter/material.dart';
import 'package:artlens/view/artwork_view.dart';
import 'package:artlens/view/artist_view.dart';
import 'package:artlens/view/home_view.dart';
import 'package:artlens/view/camera_view.dart';
import 'package:artlens/view/map_view.dart';
import 'package:artlens/view_model/app_facade.dart'; // Make sure to import AppFacade

class Routes {
  static const String home = '/';
  static const String artwork = '/artwork';
  static const String camera = '/camera';
  static const String artist = '/artist';
  static const String map = '/map';

  // Now this function receives the appFacade as an argument
  static Route<dynamic> generateRoute(RouteSettings settings, AppFacade appFacade) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeView());

      case artwork:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final int id = args['id'] ?? 0; // You might want to use id from args if applicable
          return MaterialPageRoute(
            builder: (_) => ArtworkView(id: id, appFacade: appFacade), // Pass appFacade here
          );
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Invalid arguments for ${settings.name}')),
          ),
        );

      case camera:
        return MaterialPageRoute(builder: (_) => CameraPreviewScreen());

      case artist:
        return MaterialPageRoute(builder: (_) => ArtistView());

      case map:
        return MaterialPageRoute(builder: (_) => MapView());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
