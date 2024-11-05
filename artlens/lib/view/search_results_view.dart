import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/facade.dart';
import '../view_model/search_cubit.dart';
import '../entities/artwork.dart';
import '../entities/artist.dart';
import '../entities/museum.dart';
import '../routes.dart';
import '../widgets/custom_app_bar.dart';
import '../model/firestore_service.dart'; // Import FirestoreService
import 'package:connectivity_plus/connectivity_plus.dart'; // Importa el paquete de conectividad

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class SearchResultsView extends StatefulWidget {

  final String initialQuery;
  final AppFacade appFacade;

  const SearchResultsView({Key? key, required this.initialQuery, required this.appFacade}) : super(key: key);

  @override
  _SearchResultsViewState createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  late TextEditingController _controller;
  final FirestoreService _firestoreService = FirestoreService(); // Instancia de FirestoreService
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _controller = TextEditingController(text: widget.initialQuery);
    widget.appFacade.fetchInitialSearchData();
    widget.appFacade.filterSearchResults(widget.initialQuery);
  }


  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult[0] != ConnectivityResult.none;
    });

    // Escucha los cambios de conectividad
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      setState(() {
        _isOnline = connectivityResult[0] != ConnectivityResult.none;
      });
    });

    if (!_isOnline) {
      _showNoConnectionDialog();
    } else {
      widget.appFacade.fetchInitialSearchData();
      widget.appFacade.filterSearchResults(widget.initialQuery);
    }
  }


  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo al tocar fuera
      builder: (context) {
        return AlertDialog(
          title: Text("No Internet Connection"),
          content: Text("Please check your connection and try again."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Future.delayed(Duration(seconds: 2)); // Espera 2 segundos
                await _checkConnectivity(); // Vuelve a verificar la conexión
              },
              child: Text("Retry"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "SEARCH RESULTS", showProfileIcon: true, showBackArrow: true),
      body: _isOnline ? _buildOnlineContent() : _buildOfflineMessage(),
    );
  }

  Widget _buildOfflineMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("You need internet connection", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOnlineContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _controller,
        cursorColor: Colors.black,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Find art, artist, or museum',
          hintStyle: TextStyle(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.w500),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
        onChanged: (query) {
          widget.appFacade.filterSearchResults(query);
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: widget.appFacade.searchCubit,
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SearchLoaded || state is SearchFiltered) {
          final artworks = (state is SearchLoaded) ? state.artworks : (state as SearchFiltered).filteredArtworks;
          final artists = (state is SearchLoaded) ? state.artists : (state as SearchFiltered).filteredArtists;
          final museums = (state is SearchLoaded) ? state.museums : (state as SearchFiltered).filteredMuseums;

          return ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: RawScrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(15),
              thumbColor: Theme.of(context).colorScheme.secondary,
              child: ListView(
                children: [
                  if (artworks.isNotEmpty) _buildSection("Artworks", artworks),
                  if (artists.isNotEmpty) _buildSection("Artists", artists),
                  if (museums.isNotEmpty) _buildSection("Museums", museums),
                ],
              ),
            ),
          );
        } else if (state is SearchError) {
          widget.appFacade.fetchInitialSearchData();
          widget.appFacade.filterSearchResults(widget.initialQuery);
          return Center(child: Text('Loading...'));
        } else {
          return const Center(child: Text("No results to display"));
        }
      },
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => _buildListItem(item)).toList(),
        const Divider(thickness: 1, height: 32),
      ],
    );
  }

  Widget _buildListItem(dynamic item) {
    String name;
    String? imageUrl;
    String route;
    String itemType; // Tipo de elemento para el registro en Firestore
    Map<String, dynamic> arguments;

    if (item is Artwork) {
      name = item.name;
      imageUrl = item.image;
      route = Routes.artwork;
      itemType = "Artwork";
      arguments = {'id': item.id};
    } else if (item is Artist) {
      name = item.name;
      imageUrl = item.image;
      route = Routes.artist;
      itemType = "Artist";
      arguments = {'artist': item};
    } else if (item is Museum) {
      name = item.name;
      imageUrl = item.image;
      route = Routes.museum; // Cambiado de map a museum
      itemType = "Museum";
      arguments = {'museum': item}; // Pasar el objeto completo de Museum
    }
    else {
      return Container();
    }

    return GestureDetector(
      onTap: () async {
        // Navegar primero
        Navigator.pushNamed(context, route, arguments: arguments);

        // Registrar la búsqueda en Firestore
        try {
          await _firestoreService.addDocument('BQ34', {
            'Search': itemType,
            'Date': DateTime.now(),
          });
          print("Search for $itemType logged in Firestore.");
        } catch (e) {
          print("Error logging search: $e");
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.image, size: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
