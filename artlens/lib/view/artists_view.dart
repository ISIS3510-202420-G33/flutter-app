import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes.dart';
import '../view_model/facade.dart';
import '../view_model/artist_cubit.dart';
import '../entities/artist.dart';
import '../widgets/custom_app_bar.dart';

class ArtistsView extends StatefulWidget {
  final AppFacade appFacade;

  const ArtistsView({Key? key, required this.appFacade}) : super(key: key);

  @override
  _ArtistsViewState createState() => _ArtistsViewState();
}

class _ArtistsViewState extends State<ArtistsView> {
  @override
  void initState() {
    super.initState();
    widget.appFacade.fetchAllArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "ARTISTS", showProfileIcon: true, showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ArtistCubit, ArtistState>(
          bloc: widget.appFacade.artistCubit,
          builder: (context, state) {
            if (state is ArtistLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ArtistsLoaded) {
              // Agrupar artistas alfabéticamente
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
                      ...artists.map((artist) => _buildArtistItem(artist)).toList(),
                      const Divider(thickness: 1, height: 32),
                    ],
                  );
                },
              );
            } else if (state is Error) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text("No artists to display"));
            }
          },
        ),
      ),
    );
  }

  Widget _buildArtistItem(Artist artist) {
    return GestureDetector(
      onTap: () {
        // Navegar a la vista del artista
        Navigator.pushNamed(context, Routes.artist, arguments: {'artist': artist});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            if (artist.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  artist.image!,
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

  // Método para agrupar los artistas por la letra inicial del nombre
  Map<String, List<Artist>> _groupArtistsByLetter(List<Artist> artists) {
    // Ordenar artistas alfabéticamente
    artists.sort((a, b) => a.name.compareTo(b.name));

    final Map<String, List<Artist>> groupedArtists = {};
    for (var artist in artists) {
      final letter = artist.name[0].toUpperCase();
      if (groupedArtists[letter] == null) {
        groupedArtists[letter] = [];
      }
      groupedArtists[letter]!.add(artist);
    }
    return groupedArtists;
  }
}
