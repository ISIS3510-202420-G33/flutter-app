// /lib/main.dart
import 'package:flutter/material.dart';
import 'package:artlens/routes.dart';
import 'package:artlens/view_model/facade.dart';
import 'package:artlens/view_model/artwork_cubit.dart';
import 'package:artlens/view_model/artist_cubit.dart';
import 'package:artlens/view_model/museum_cubit.dart';
import 'package:artlens/model/artwork_service.dart';
import 'package:artlens/model/artist_service.dart';
import 'package:artlens/model/museum_service.dart';

void main() {
  final artworkCubit = ArtworkCubit(ArtworkService(), ArtistService(), MuseumService());
  final artistCubit = ArtistCubit(ArtistService());
  final museumCubit = MuseumCubit(MuseumService());
  final appFacade = AppFacade(artworkCubit, artistCubit, museumCubit);

  runApp(ArtLensApp(appFacade: appFacade));
}

class ArtLensApp extends StatelessWidget {
  final AppFacade appFacade;

  const ArtLensApp({Key? key, required this.appFacade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ArtLens',
        theme: ThemeData(
          fontFamily: 'OpenSans',
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme(
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Color(0xFFA0522D),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
            error: Colors.red,
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        initialRoute: Routes.home,
        onGenerateRoute: (settings) {

          // DESCOMENTAR ESTA SECCION PARA PODER PROBAR DESDE EL EMULADOR SIN LEER CODIGO QR
          //if (settings.name == Routes.artwork) {
          //  return Routes.generateRoute(RouteSettings(
          //    name: Routes.artwork,
          //    arguments: {'id': 1},
          //  ), appFacade);
          // }

          return Routes.generateRoute(settings, appFacade);
          },
        );
    }
}