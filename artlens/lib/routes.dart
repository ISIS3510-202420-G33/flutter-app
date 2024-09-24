import 'package:flutter/material.dart';
import 'package:artlens/views/artwork_view.dart';
import 'package:artlens/views/artist_view.dart';
import 'package:artlens/views/home_view.dart';
import 'package:artlens/views/camera_view.dart';
import 'package:artlens/views/map_view.dart';

class Routes {
  static const String home = '/';
  static const String artwork = '/artwork';
  static const String camera = '/camera';
  static const String artist = '/artist';
  static const String map = '/map';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeView());

      case artwork:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final int id = args['id'] ?? 0;
          return MaterialPageRoute(
            builder: (_) => ArtworkView(id: id), // Pass the argument to ArtworkView
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
