import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes.dart';
import '../entities/artwork.dart';
import '../entities/artist.dart';
import '../view_model/facade.dart';
import '../view_model/artwork_cubit.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class ArtistView extends StatefulWidget {
  final Artist artist;
  final AppFacade appFacade;

  const ArtistView({
    Key? key,
    required this.artist,
    required this.appFacade,
  }) : super(key: key);

  @override
  _ArtistViewState createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    widget.appFacade.fetchArtworksByArtistId(widget.artist.id);
  }

  // Método para manejar la navegación
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else if (index == 1) {
        Navigator.pushNamed(context, Routes.camera);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: "HOME", showProfileIcon: true,showBackArrow: true),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: RawScrollbar(
          thumbVisibility: true,
          thickness: 6.0,
          radius: const Radius.circular(15),
          thumbColor: theme.colorScheme.secondary,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen del artista
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.artist.image),
                  ),
                ),
                // Nombre del artista
                Text(
                  widget.artist.name,
                  style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                // Biografía del artista
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.artist.biography,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(height: 20),
                // Obras destacadas del artista
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Highlighted Artworks",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                BlocBuilder<ArtworkCubit, ArtworkState>(
                  bloc: widget.appFacade.artworkCubit,
                  builder: (context, state) {
                    if (state is ArtworkLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ArtworkLoaded) {
                      return _buildArtworksCarousel(state.artworksByArtistId);
                    } else if (state is ArtworkError) {
                      return Center(child: Text('Error loading artworks: ${state.message}'));
                    } else {
                      return Center(child: Text('No artworks available.'));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildArtworksCarousel(List<Artwork>? artworks) {
    if (artworks == null || artworks.isEmpty) {
      return Center(child: Text('No artworks available.'));
    }
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: artworks.length,
        itemBuilder: (context, index) {
          final artwork = artworks[index];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.artwork,
                arguments: {'id': artwork.id},
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      artwork.image,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    artwork.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
