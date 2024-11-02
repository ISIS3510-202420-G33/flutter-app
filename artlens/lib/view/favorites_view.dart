import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../view_model/favorites_cubit.dart';
import '../view_model/connectivity_cubit.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../entities/artwork.dart';
import '../routes.dart';
import '../view_model/facade.dart';
import 'dart:io';

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
    widget.appFacade.fetchFavorites();
    _printHiveDatabaseState(); // Llamada para imprimir el estado de Hive al iniciar
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

  void _showNoConnectionMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Oops! It seems you're offline. Please check your connection."),
      ),
    );
  }

  // Función para truncar texto a un número máximo de palabras y agregar "..."
  String _truncateWords(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return '${words.sublist(0, maxWords).join(' ')}...';
    }
    return text;
  }

  // Método para imprimir el estado de la base de datos de Hive
  Future<void> _printHiveDatabaseState() async {
    final favoritesBox = Hive.box<Artwork>('favoritesArtworks');
    print("=== Estado de la base de datos de Hive ===");
    print("Total de elementos en Hive: ${favoritesBox.length}");

    for (var artwork in favoritesBox.values) {
      print("Artwork ID: ${artwork.id}");
      print("Name: ${artwork.name}");
      print("Local Image Path: ${artwork.localImagePath}");
      print("Local Image Exists: ${artwork.localImagePath != null && File(artwork.localImagePath!).existsSync()}");
    }
    print("=========================================");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "FAVORITES", showProfileIcon: false),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, connectivityState) {
          final isOnline = connectivityState is ConnectivityOnline;

          return BlocBuilder<FavoritesCubit, FavoritesState>(
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

                        // Verificar si la imagen local existe
                        final localImagePath = artwork.localImagePath;
                        final localImageExists = localImagePath != null && File(localImagePath).existsSync();

                        // Imprimir la información de la imagen en la consola
                        print("Artwork ID: ${artwork.id}");
                        print("Local Image Path: $localImagePath");
                        print("Local Image Exists: $localImageExists");
                        print("Network Image URL: ${artwork.image}");

                        return GestureDetector(
                          onTap: () {
                            if (isOnline) {
                              Navigator.pushNamed(
                                context,
                                Routes.artwork,
                                arguments: {'id': artwork.id},
                              ).then((_) {
                                widget.appFacade.fetchFavorites();
                              });
                            } else {
                              _showNoConnectionMessage(context);
                            }
                          },
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Verifica si hay una imagen local disponible; de lo contrario, usa la imagen de red
                                  localImageExists
                                      ? Image.file(
                                    File(localImagePath!),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.network(
                                    artwork.image,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print("Error loading network image for ${artwork.name}");
                                      return Icon(Icons.image_not_supported, size: 100);
                                    },
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
                                        Text(
                                          _truncateWords(artwork.interpretation, 20),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      if (isOnline) {
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
                                      } else {
                                        _showNoConnectionMessage(context);
                                      }
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: iconPressed
                                          ? Theme.of(context).colorScheme.secondary
                                          : Colors.black,
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
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
