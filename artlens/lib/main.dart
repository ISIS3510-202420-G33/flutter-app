// /lib/main.dart
import 'package:flutter/material.dart';
import 'package:artlens/routes.dart'; // Import the routes
import 'package:artlens/view_model/app_facade.dart'; // Importa AppFacade
import 'package:artlens/view_model/artwork_cubit.dart'; // Importa el Cubit que necesitas
import 'package:artlens/model/artwork_service.dart'; // Importa el ArtworkService

void main() {
  final artworkCubit = ArtworkCubit(ArtworkService());
  final appFacade = AppFacade(artworkCubit); // Crea la instancia de AppFacade

  runApp(ArtLensApp(appFacade: appFacade));
}

class ArtLensApp extends StatelessWidget {
  final AppFacade appFacade; // Recibe el AppFacade como parámetro

  const ArtLensApp({Key? key, required this.appFacade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ArtLens',
        theme: ThemeData(
          fontFamily: 'OpenSans', // Apply OpenSans globally
          primaryColor: Colors.white, // Primary color as white
          scaffoldBackgroundColor: Colors.white, // Ensures the background is white as well
          colorScheme: const ColorScheme(
            primary: Colors.white, // White for primary
            onPrimary: Colors.black, // Black for contrast text on primary
            secondary: Color(0xFFA0522D), // Accent color #A0522D (brownish)
            onSecondary: Colors.white, // Contrast for secondary
            surface: Colors.white,
            onSurface: Colors.black, // Black contrast for surface
            error: Colors.red, // Error color
            onError: Colors.white, // Contrast for error
            brightness: Brightness.light, // Light theme
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),  // Extra bold title
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800), // Extra bold large title
            bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),    // Large body text
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),   // Medium body text
          ),
        ),
        initialRoute: Routes.artwork, // Definir que el artwork sea la ruta inicial
        onGenerateRoute: (settings) {
          // Aquí controlas las rutas
          if (settings.name == Routes.artwork) {
            // Si es la ruta de artwork, pasa id: 1 por defecto
            return Routes.generateRoute(RouteSettings(
              name: Routes.artwork,
              arguments: {'id': 1}, // Pasa el id: 1 aquí
            ), appFacade);
          }
          // Para las demás rutas, usa la configuración estándar
          return Routes.generateRoute(settings, appFacade);
          },
        );
    }
}