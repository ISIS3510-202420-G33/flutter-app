import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes.dart';
import '../view_model/facade.dart';
import '../view_model/artist_cubit.dart';
import '../view_model/connectivity_cubit.dart';
import '../entities/artist.dart';
import '../widgets/custom_app_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ArtistsView extends StatefulWidget {
  final AppFacade appFacade;

  const ArtistsView({Key? key, required this.appFacade}) : super(key: key);

  @override
  _ArtistsViewState createState() => _ArtistsViewState();
}

class _ArtistsViewState extends State<ArtistsView> {
  bool isOnline = true;
  bool isFetch = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult[0] != ConnectivityResult.none;
    if (isOnline) {
      isFetch = true;
      widget.appFacade.fetchAllArtists();
    } else {
      if (isFetch) {
        setState(() {
          isOnline = false;
        });
      } else {
        widget.appFacade.fetchAllArtists();
      }
    }
  }

  void _handleConnectivityChange(BuildContext context, ConnectivityState state) {
    if (state is ConnectivityOffline) {
      setState(() {
        isOnline = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection lost. Some features may not be available.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (state is ConnectivityOnline) {
      if (!isFetch) {
        Future.delayed(const Duration(seconds: 5), () {
          isFetch = true;
          widget.appFacade.fetchAllArtists();
        });
      } else {
        setState(() {
          isOnline = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection restored.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "ARTISTS", showProfileIcon: true, showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MultiBlocListener(
          listeners: [
            BlocListener<ConnectivityCubit, ConnectivityState>(
              listener: _handleConnectivityChange,
            )
          ],
          child: BlocBuilder<ArtistCubit, ArtistState>(
            bloc: widget.appFacade.artistCubit,
            builder: (context, state) {
              if (state is ArtistLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ArtistsLoaded) {
                final groupedArtists = _groupArtistsByLetter(state.artists);
                return ListView.builder(
                  itemCount: groupedArtists.length,
                  itemBuilder: (context, index) {
                    final letter = groupedArtists.keys.elementAt(index);
                    final artists = groupedArtists[letter]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            letter,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...artists.map((artist) => _buildArtistItem(artist)),
                        const Divider(thickness: 1, height: 32),
                      ],
                    );
                  },
                );
              } else if (state is Error) {
                return Center(
                  child: Text(
                    isOnline
                        ? 'Error loading artists: ${state.message}'
                        : "No internet connection. Waiting for connection...",
                    textAlign: TextAlign.center,
                  )
                );
              } else {
                return const Center(
                    child: Text(
                      "Unexpected error occurred",
                      textAlign: TextAlign.center,
                    )
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildArtistItem(Artist artist) {
    return GestureDetector(
      onTap: isOnline
          ? () {
        Navigator.pushNamed(context, Routes.artist, arguments: {'artist': artist});
      }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                artist.image,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                artist.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to group artists by the first letter of their name
  Map<String, List<Artist>> _groupArtistsByLetter(List<Artist> artists) {
    artists.sort((a, b) => a.name.compareTo(b.name));
    final Map<String, List<Artist>> groupedArtists = {};
    for (var artist in artists) {
      final letter = artist.name[0].toUpperCase();
      groupedArtists.putIfAbsent(letter, () => []).add(artist);
    }
    return groupedArtists;
  }
}
