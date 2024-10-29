import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes.dart';
import '../entities/artwork.dart';
import '../entities/museum.dart';
import '../view_model/facade.dart';
import '../view_model/museum_artwork_cubit.dart'; // Importar el cubit de museum artworks
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MuseumView extends StatefulWidget {
  final Museum museum;
  final AppFacade appFacade;

  const MuseumView({
    Key? key,
    required this.museum,
    required this.appFacade,
  }) : super(key: key);

  @override
  _MuseumViewState createState() => _MuseumViewState();
}

class _MuseumViewState extends State<MuseumView> with RouteAware {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchArtworksIfNeeded();
  }

  void _fetchArtworksIfNeeded() {
    print("Fetching artworks for museum in view");
    widget.appFacade.fetchArtworksByMuseumId(widget.museum.id); // Llama al método de MuseumArtworkCubit
  }

  @override
  void didPopNext() {
    print("Returned to MuseumView, forcing reload of artworks");
    widget.appFacade.museumArtworkCubit.forceReloadArtworksForMuseum(widget.museum.id);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else if (index == 1) {
        Navigator.pushNamed(context, Routes.camera);
      } else if (index == 2) {
        Navigator.pushNamed(context, Routes.trending);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserver<ModalRoute<void>>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    RouteObserver<ModalRoute<void>>().unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: "MUSEUM", showProfileIcon: true, showBackArrow: true),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      widget.museum.image,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  widget.museum.name,
                  style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.museum.description,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 16),
                BlocBuilder<MuseumArtworkCubit, MuseumArtworkState>(
                  bloc: widget.appFacade.museumArtworkCubit, // Utiliza el nuevo cubit específico
                  builder: (context, state) {
                    print("MuseumArtworkCubit state: $state");

                    if (state is MuseumArtworkLoading) {
                      print("Artwork loading...");
                      return Center(child: CircularProgressIndicator());
                    } else if (state is MuseumArtworkLoaded) {
                      print("Artwork loaded for museum with ${state.artworksByMuseumId.length} artworks");
                      return _buildArtworksCarousel(state.artworksByMuseumId);
                    } else if (state is MuseumArtworkError) {
                      print("Artwork error: ${state.message}");
                      return Center(child: Text('Error loading artworks: ${state.message}'));
                    } else {
                      print("No artworks available state encountered");
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
      print("No artworks found to display in carousel.");
      return Center(child: Text('No artworks available.'));
    }
    print("Displaying artworks carousel with ${artworks.length} items.");
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: artworks.length,
        itemBuilder: (context, index) {
          final artwork = artworks[index];
          return GestureDetector(
            onTap: () {
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
                  const SizedBox(height: 8),
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
