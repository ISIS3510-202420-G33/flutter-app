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
import 'package:artlens/view_model/analytic_engine_cubit.dart';
import 'package:artlens/model/artwork_service.dart';
import 'package:artlens/model/analytic_engine_service.dart';
import 'package:artlens/model/artist_service.dart';
import 'package:artlens/model/museum_service.dart';
import 'package:artlens/model/comments_service.dart';
import 'package:artlens/model/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences before building the app
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final artworkCubit = ArtworkCubit(ArtworkService(), ArtistService(), MuseumService());
  final artistCubit = ArtistCubit(ArtistService());
  final museumCubit = MuseumCubit(MuseumService());
  final commentsCubit = CommentsCubit(CommentsService());
  final authCubit = AuthCubit();
  final userService = UserService();
  final favoritesCubit = FavoritesCubit(userService);
  final analyticEngineCubit = AnalyticEngineCubit(AnalyticEngineService());

  final appFacade = AppFacade(
    artworkCubit: artworkCubit,
    artistCubit: artistCubit,
    museumCubit: museumCubit,
    authCubit: authCubit,
    userService: userService,
    commentsCubit: commentsCubit,
    favoritesCubit: favoritesCubit,
    analyticEngineCubit: analyticEngineCubit,
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
        BlocProvider(create: (_) => analyticEngineCubit)
      ],
      child: ArtLensApp(appFacade: AppFacade(artworkCubit: artworkCubit, artistCubit: artistCubit, museumCubit: museumCubit, authCubit: authCubit, favoritesCubit: favoritesCubit, commentsCubit: commentsCubit, userService: userService, analyticEngineCubit: analyticEngineCubit),),
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
