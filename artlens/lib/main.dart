import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:artlens/routes.dart';
import 'package:artlens/view_model/facade.dart';
import 'package:artlens/view_model/artwork_cubit.dart';
import 'package:artlens/view_model/artist_cubit.dart';
import 'package:artlens/view_model/museum_cubit.dart';
import 'package:artlens/view_model/auth_cubit.dart'; // Import AuthCubit
import 'package:artlens/view_model/favorites_cubit.dart'; // Import FavoritesCubit
import 'package:artlens/model/artwork_service.dart';
import 'package:artlens/model/artist_service.dart';
import 'package:artlens/model/museum_service.dart';
import 'package:artlens/model/user_service.dart'; // Import UserService
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is properly initialized before async code

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences before building the app
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final artworkCubit = ArtworkCubit(ArtworkService(), ArtistService(), MuseumService());
  final artistCubit = ArtistCubit(ArtistService());
  final museumCubit = MuseumCubit(MuseumService());
  final authCubit = AuthCubit(); // Instanciar AuthCubit
  final userService = UserService(); // Instanciar UserService
  final favoritesCubit = FavoritesCubit(userService); // Pasar el UserService a FavoritesCubit
  final appFacade = AppFacade(
    artworkCubit: artworkCubit,
    artistCubit: artistCubit,
    museumCubit: museumCubit,
    authCubit: authCubit,
    userService: userService,
    favoritesCubit: favoritesCubit, // Asegurarse de agregar FavoritesCubit
  );
  runApp(ArtLensApp(appFacade: appFacade));
  // Load saved session, if any
  await appFacade.loadSession();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => appFacade),
        BlocProvider(create: (_) => artworkCubit),
        BlocProvider(create: (_) => artistCubit),
        BlocProvider(create: (_) => museumCubit),
        BlocProvider(create: (_) => authCubit),
        BlocProvider(create: (_) => favoritesCubit), // Agregar FavoritesCubit al BlocProvider
      ],
      child: ArtLensApp(appFacade: AppFacade(artworkCubit: artworkCubit, artistCubit: artistCubit, museumCubit: museumCubit, authCubit: authCubit, favoritesCubit: favoritesCubit, userService: userService),),
    ),
  );
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
     //DESCOMENTAR ESTA SECCION PARA PODER PROBAR DESDE EL EMULADOR SIN LEER CODIGO QR
        //if (settings.name == Routes.artwork) {
        //  return Routes.generateRoute(RouteSettings(
        //    name: Routes.artwork,
        //    arguments: {'id': 1},
        //  ), appFacade);
        //}
        return Routes.generateRoute(settings, appFacade);
         }
    );
  }
}
