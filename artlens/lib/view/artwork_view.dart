import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Importa Flutter TTS
import '../routes.dart';
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

class ArtworkView extends StatefulWidget {
  final int id;
  final AppFacade appFacade;

  const ArtworkView({
    Key? key,
    required this.id,
    required this.appFacade,
  }) : super(key: key);

  @override
  _ArtworkViewState createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  int _selectedIndex = 1;
  bool _isLiked = false;
  bool _isForumOpen = false;
  bool _isPlaying = false; // Controlar si el TTS está reproduciendo
  final TextEditingController _commentController = TextEditingController();

  // Instancia de FlutterTTS
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    print("Hola " + widget.id.toString());
    widget.appFacade.fetchArtworkAndRelatedEntities(widget.id);

    // Configura los parámetros iniciales de TTS
    flutterTts.setLanguage('en-US'); // Cambia el idioma según tu preferencia
    flutterTts.setSpeechRate(0.5); // Velocidad de la narración
  }

  @override
  void dispose() {
    flutterTts.stop(); // Asegúrate de detener cualquier narración en progreso al salir
    super.dispose();
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

  void _onLikePressed() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _toggleForum() {
    setState(() {
      _isForumOpen = !_isForumOpen;
    });
  }

  // Método para enviar un comentario
  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        // Lógica para agregar comentario (puedes añadir lógica adicional para mandar el comentario a un servidor)
        _commentController.clear();
      });
    }
  }

  // Método para iniciar la narración de TTS
  Future<void> _startTTS(String text) async {
    if (_isPlaying) {
      await flutterTts.pause(); // Pausar si ya está reproduciendo
      setState(() {
        _isPlaying = false;
      });
    } else {
      await flutterTts.speak(text); // Iniciar la narración
      setState(() {
        _isPlaying = true;
      });
    }
  }

  // Método para detener la narración de TTS
  Future<void> _stopTTS() async {
    await flutterTts.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: "HOME", showProfileIcon: true, showBackArrow: true),
      body: BlocBuilder<ArtworkCubit, ArtworkState>(
        bloc: widget.appFacade.artworkCubit,
        builder: (context, state) {
          if (state is ArtworkLoading) {
            // Muestra un spinner de carga mientras los datos se cargan
            return Center(child: CircularProgressIndicator());
          } else if (state is ArtworkLoaded) {
            final artwork = state.artwork;
            final artist = state.artist;
            final museum = state.museum;

            return ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: RawScrollbar(
                thumbVisibility: true,
                thickness: 6.0,
                radius: const Radius.circular(15),
                thumbColor: theme.colorScheme.secondary,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Renderizado del título y botón "me gusta"
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, left: 80.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 32.0),
                                child: Center(
                                  child: Text(
                                    artwork?.name ?? "Unknown Artwork",
                                    style: theme.textTheme.headlineMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: _isLiked ? theme.colorScheme.secondary : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(Icons.star, color: Colors.white),
                                ),
                              ),
                              onPressed: _onLikePressed, // Alternar estado "me gusta"
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Imagen de la obra de arte
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 280, maxHeight: 350),
                          child: Image.network(
                            artwork?.image ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descripción básica de la obra de arte
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0, top: 16.0),
                        child: Text(
                          "Artist: ${artist?.name}\n"
                              "Technique: ${artwork?.technique ?? "N/A"}\n"
                              "Dimensions: ${artwork?.dimensions ?? "N/A"}\n"
                              "Museum: ${museum?.name ?? "N/A"}",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón para ver detalles del artista
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: SizedBox(
                          width: 328,
                          height: 39,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (artist != null) {
                                Navigator.pushNamed(
                                  context,
                                  Routes.artist,
                                  arguments: {'artist': artist},
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Artist details are not available')),
                                );
                              }
                            },
                            child: Text(
                              "View Artist Details",
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón de reproducción de audio (Text-to-Speech)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow, // Cambia el icono según el estado
                              color: Colors.black,
                              size: 40,
                            ),
                            padding: const EdgeInsets.only(left: 20.0),
                            onPressed: () {
                              if (_isPlaying) {
                                _stopTTS();
                              } else {
                                _startTTS(artwork?.interpretation ?? "No interpretation available");
                              }
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Click the icon to start the audio narration.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Descripción extendida
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
                        child: Text(
                          artwork?.interpretation ?? "Unknown Interpretation",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),

                      // Botón para alternar la vista del foro
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0, bottom: 14),
                        child: SizedBox(
                          width: 328,
                          height: 39,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _toggleForum,
                            child: Text(
                              _isForumOpen ? "Close Forum" : "Open Forum",
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),

                      // Sección del foro visible solo cuando el foro está abierto
                      if (_isForumOpen) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  hintText: 'Write your comment...',
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 150,
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _submitComment,
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Renderizado de comentarios desde el estado cargado
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.comments?.length ?? 0,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(state.comments![index].content),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          } else if (state is ArtworkError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: const Text('No artwork selected.'));
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
