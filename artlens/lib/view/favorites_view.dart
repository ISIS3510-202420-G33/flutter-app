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
  Map<int, bool> isPressed = {}; // Map para controlar qué íconos han sido presionados

  @override
  void initState() {
    super.initState();
    widget.appFacade.fetchFavorites();  }

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
    return Scaffold(
      appBar: CustomAppBar(title: "FAVORITES", showProfileIcon: false),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is Error) {
            return Center(child: Text('Error loading favorites: ${state.message}'));
          }

          if (state is FavoritesLoaded && state.favorites.isEmpty) {
            return Center(child: Text('No favorites found.'));
          }

          if (state is FavoritesLoaded) {
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
                            crossAxisAlignment: CrossAxisAlignment.center,  // Center all row content vertically
                            children: [
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
                                    // Truncate the interpretation text here
                                    Text(
                                      _truncateWords(artwork.interpretation, 20), // Adjust word limit as needed
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    isPressed[artwork.id] = true;
                                  });

                                  // Short delay before executing delete and restoring color
                                  await Future.delayed(const Duration(milliseconds: 500));

                                  widget.appFacade.removeFavorite(artwork.id);

                                  // Restore the icon's color state
                                  setState(() {
                                    isPressed[artwork.id] = false;
                                  });
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: iconPressed
                                      ? Theme.of(context).colorScheme.secondary // Change to secondary color when pressed
                                      : Colors.black, // Original color
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
          }

          return Center(child: const Text('No favorites available.'));
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex, // Start with index 2 for favorites
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
