import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/favorites_cubit.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../entities/artwork.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';
import '../view_model/facade.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class FavoritesView extends StatefulWidget {
  final AppFacade appFacade;

  const FavoritesView({
    Key? key,
    required this.appFacade,
  }) : super(key: key);

  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  int _selectedIndex = 2;
  int? userId;
  Map<int, bool> isPressed = {}; // Map para controlar qué íconos han sido presionados

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Carga el userId desde SharedPreferences y luego obtiene los favoritos
  }

  // Carga el userId desde SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });

    if (userId != null) {
      widget.appFacade.fetchFavorites();
    }
  }

  // Método para manejar la navegación de la barra inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } else if (index == 1) {
      Navigator.pushNamed(context, Routes.camera);
    } else if (index == 2) {
      Navigator.pushNamed(context, Routes.trending);
    }
  }

  // Función para truncar texto (interpretación) a una longitud específica y agregar "..."
  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    }
    return text;
  }

  // Alternativamente, puedes limitar la cantidad de palabras en lugar de caracteres:
  String _truncateWords(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return '${words.sublist(0, maxWords).join(' ')}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final favoritesCubit = context.read<FavoritesCubit>();

    return Scaffold(
      appBar: CustomAppBar(title: "FAVORITES", showProfileIcon: false),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('Error loading favorites: ${state.error}'));
          }

          if (state.favorites.isEmpty) {
            return Center(child: Text('No favorites found.'));
          }

          return ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: RawScrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(15),
              thumbColor: Theme.of(context).colorScheme.secondary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final Artwork artwork = state.favorites[index];
                  bool iconPressed = isPressed[artwork.id] ?? false;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.artwork,
                        arguments: {'id': artwork.id},
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,  // Centrar verticalmente todo el contenido de la fila
                          children: [
                            // Imagen centrada verticalmente
                            Image.network(
                              artwork.image,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    artwork.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  // Aquí se trunca el texto de la interpretación
                                  Text(
                                    _truncateWords(artwork.interpretation, 20), // Puedes ajustar el límite de palabras
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            // Icono de eliminación con efecto de color al ser presionado
                            InkWell(
                              onTap: () async {
                                // Cambiar el estado del icono a "presionado"
                                setState(() {
                                  isPressed[artwork.id] = true;
                                });

                                // Espera medio segundo antes de ejecutar la eliminación y restaurar el color
                                await Future.delayed(const Duration(milliseconds: 500));

                                if (userId != null) {
                                  favoritesCubit.removeFavorite(userId!, artwork.id);
                                }

                                // Restaurar el estado del icono a "no presionado"
                                setState(() {
                                  isPressed[artwork.id] = false;
                                });
                              },
                              child: Icon(
                                Icons.delete,
                                color: iconPressed
                                    ? Theme.of(context).colorScheme.secondary // Cambia a naranja cuando se presiona
                                    : Colors.black, // Color original
                              ),
                            ),
                          ],
                        ),
                        const Divider(thickness: 1, height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex, // Aquí manejamos el índice seleccionado, comenzando con 2 para favoritos
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
