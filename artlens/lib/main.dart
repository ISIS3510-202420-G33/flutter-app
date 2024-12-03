import 'package:artlens/view_model/connectivity_cubit.dart';
import 'package:artlens/view_model/isFavorite_cubit.dart';
import 'package:artlens/view_model/museum_artwork_cubit.dart';
import 'package:artlens/view_model/search_cubit.dart';
import 'package:artlens/view_model/spotlight_artworks_cubit.dart';
import 'package:artlens/view_model/recommendations_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:artlens/routes.dart';
import 'package:artlens/view_model/facade.dart';
import 'package:artlens/view_model/artwork_cubit.dart';
import 'package:artlens/view_model/artist_cubit.dart';
import 'package:artlens/view_model/museum_cubit.dart';
import 'package:artlens/view_model/auth_cubit.dart';
import 'package:artlens/view_model/favorites_cubit.dart';
import 'package:artlens/view_model/comments_cubit.dart';
import 'package:artlens/view_model/map_cubit.dart';
import 'package:artlens/model/artwork_service.dart';
import 'package:artlens/model/analytic_engine_service.dart';
import 'package:artlens/model/artist_service.dart';
import 'package:artlens/model/museum_service.dart';
import 'package:artlens/model/comments_service.dart';
import 'package:artlens/model/user_service.dart';
import 'package:artlens/model/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'entities/artwork.dart';
import 'firebase_options.dart';

/// Inicializar un RouteObserver para seguir las rutas
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ArtworkAdapter());

  // Open necessary Hive boxes
  await Hive.openBox<Artwork>('spotlightArtworks');
  await Hive.openBox<Artwork>('favoritesArtworks');

  await Hive.openBox('metadata'); // For storing metadata like last refresh date

  // Initialize SharedPreferences before building the app
  await SharedPreferences.getInstance();

  final artworkCubit = ArtworkCubit(ArtworkService(), ArtistService(), MuseumService());
  final artistCubit = ArtistCubit(ArtistService());
  final museumCubit = MuseumCubit(MuseumService());
  final commentsCubit = CommentsCubit(CommentsService());
  final authCubit = AuthCubit();
  final userService = UserService();
  final favoritesCubit = FavoritesCubit(userService);
  final mapCubit = MapCubit(AnalyticEngineService());
  final spotlightArtworksCubit = SpotlightArtworksCubit(AnalyticEngineService());
  final recommendationsCubit = RecommendationsCubit(AnalyticEngineService());
  final searchCubit=SearchCubit(ArtworkService(), MuseumService(), ArtistService());
  final museumArtworkCubit = MuseumArtworkCubit(ArtworkService());
  final connectivityCubit = ConnectivityCubit();
  final isFavoriteCubit = IsFavoriteCubit(userService);
  final firestoreService = FirestoreService();


  final appFacade = AppFacade(
    artworkCubit,
    artistCubit,
    commentsCubit,
    museumCubit,
    authCubit,
    favoritesCubit,
    userService,
    mapCubit,
    spotlightArtworksCubit,
    recommendationsCubit,
    searchCubit,
    museumArtworkCubit,
    connectivityCubit,
    isFavoriteCubit,
    firestoreService
  );

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
        BlocProvider(create: (_) => favoritesCubit),
        BlocProvider(create: (_) => mapCubit),
        BlocProvider(create: (_) => searchCubit),
        BlocProvider(create: (_) => connectivityCubit)
      ],
      child: ArtLensApp(appFacade: appFacade),
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


        //initialRoute: Routes.home,
        //onGenerateRoute: (settings) {
     //DESCOMENTAR ESTA SECCION PARA PODER PROBAR DESDE EL EMULADOR SIN LEER CODIGO QR
        //if (settings.name == Routes.artwork) {
        //  return Routes.generateRoute(RouteSettings(
        //    name: Routes.artwork,
        //    arguments: {'id': 1},
        //  ), appFacade);
        //}

      initialRoute: Routes.home,
      navigatorObservers: [routeObserver], // Agregar RouteObserver aquí
      onGenerateRoute: (settings) {
        // DESCOMENTAR ESTA SECCION PARA PODER PROBAR DESDE EL EMULADOR SIN LEER CODIGO QR
        // if (settings.name == Routes.artwork) {
        //   return Routes.generateRoute(RouteSettings(
        //     name: Routes.artwork,
        //     arguments: {'id': 1},
        //   ), appFacade);
        // }

        return Routes.generateRoute(settings, appFacade);
      },
    );
  }
}
