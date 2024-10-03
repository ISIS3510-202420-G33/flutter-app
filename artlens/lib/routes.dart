import 'package:flutter/material.dart';
import 'package:artlens/view/artwork_view.dart';
import 'package:artlens/view/artist_view.dart';
import 'package:artlens/view/home_view.dart';
import 'package:artlens/view/camera_view.dart';
import 'package:artlens/view/map_view.dart';
import 'package:artlens/view/login_view.dart';
import 'package:artlens/view/sign_up_view.dart';
import 'package:artlens/view/favorites_view.dart';
import 'package:artlens/view/trending_view.dart';
import 'package:artlens/view_model/facade.dart';
import 'package:artlens/entities/artist.dart';

class Routes {
  static const String home = '/';
  static const String artwork = '/artwork';
  static const String camera = '/camera';
  static const String artist = '/artist';
  static const String map = '/map';
  static const String signUp = '/signUp';
  static const String favorites = '/favorites';
  static const String trending = '/trending';
  static const String logIn = '/logIn';

  static Route<dynamic> generateRoute(RouteSettings settings, AppFacade appFacade) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeView());

      case artwork:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final int id = args['id'];
          return MaterialPageRoute(
            builder: (_) => ArtworkView(id: id, appFacade: appFacade),
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
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final Artist artist = args['artist'];
          return MaterialPageRoute(
            builder: (_) => ArtistView(artist: artist, appFacade: appFacade),
          );
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Invalid arguments for ${settings.name}')),
          ),
        );

      case map:
        return MaterialPageRoute(builder: (_) => MapView(appFacade: appFacade));

      case logIn:
        return MaterialPageRoute(builder: (_) => LogInView(appFacade: appFacade));

      case signUp:
        return MaterialPageRoute(builder: (_) => SignUpView(appFacade: appFacade));

      case favorites:
        return MaterialPageRoute(builder: (_) => FavoritesView(appFacade: appFacade));

      case trending:
        return MaterialPageRoute(builder: (_) => TrendingView(appFacade: appFacade));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
