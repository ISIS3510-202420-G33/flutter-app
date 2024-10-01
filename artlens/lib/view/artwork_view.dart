import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../model/firestore_service.dart'; // Importación del servicio de Firestore
import '../routes.dart';
import '../view_model/facade.dart';
import '../view_model/artwork_cubit.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../main.dart'; // Para usar el `RouteObserver`
import 'package:intl/intl.dart';

import 'artist_view.dart';

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

class _ArtworkViewState extends State<ArtworkView> with RouteAware {
  int? _artworkId;
  int _selectedIndex = 1;
  bool _isLiked = false;
  bool _isForumOpen = false;
  bool _isPlaying = false; // Controlar si el TTS está reproduciendo
  bool _isLoading = true; // Controlar el estado de carga de la obra de arte
  bool _isCommentsLoading = false; // Controlar el estado de carga de comentarios
  final TextEditingController _commentController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts(); // Instancia de FlutterTTS
  final FirestoreService _firestoreService = FirestoreService(); // Instancia del servicio Firestore

  @override
  void initState() {
    super.initState();
    _artworkId = widget.id;

    // Configura los parámetros iniciales de TTS
    flutterTts.setLanguage('en-US');
    flutterTts.setSpeechRate(0.5);

    // Configurar el completion handler cuando el TTS finaliza
    flutterTts.setCompletionHandler(() async {
      setState(() {
        _isPlaying = false;
      });

      // Agregar documento con acción 2 cuando el TTS se complete
      await _firestoreService.addDocument('BQ32', {
        'Acción': 2,
        'Fecha': DateTime.now(),
      });
    });

    _initializeArtwork();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registrar la vista para recibir notificaciones de rutas con RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  Future<void> _initializeArtwork() async {
    setState(() {
      _isLoading = true;
    });
    final favorites = await widget.appFacade.fetchFavorites();  // Trae las obras favoritas
    _checkIfLiked(favorites);  // Verifica si la obra está "likeada"
    widget.appFacade.fetchArtworkAndRelatedEntities(widget.id); // Vuelve a cargar la obra de arte
    setState(() {
      _isLoading = false;
    });
  }

  void _checkIfLiked(favorites) {
    _isLiked = favorites.any((artwork) => artwork.id == _artworkId);
    setState(() {});
  }

  @override
  void dispose() {
    // Desregistrar la vista para detener las notificaciones de rutas
    routeObserver.unsubscribe(this); // Ajustar con `RouteObserver`
    flutterTts.stop();  // Asegúrate de detener cualquier narración en progreso
    super.dispose();
  }

  @override
  void didPopNext() {
    _initializeArtwork();  // Vuelve a cargar los datos de la obra de arte cuando se regresa
    super.didPopNext();
  }

  // Método para manejar la navegación
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

  Future<void> _onLikePressed() async {
    try {
      if (_isLiked) {
        await widget.appFacade.removeFavorite(_artworkId!);
        setState(() {
          _isLiked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unliked')),
        );
      } else {
        await widget.appFacade.addFavorite(_artworkId!);
        setState(() {
          _isLiked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Like added'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el like')),
      );
    }
  }

  void _toggleForum() async {
    setState(() {
      _isForumOpen = !_isForumOpen;
    });
    // Si el foro se abrió, cargar los comentarios
    if (_isForumOpen) {
      await _loadComments();
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isNotEmpty) {
      String content = _commentController.text;
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _firestoreService.addDocument('BQ31', {
        'Accion': 1,
        'Fecha': DateTime.now(),
        'Usuario': "falta esto",
      });
      // Postear el comentario
      await widget.appFacade.postComment(content, date, _artworkId!);

      // Limpiar el campo del comentario
      _commentController.clear();

      // Forzar la recarga completa de la vista
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ArtworkView(
            id: _artworkId!,
            appFacade: widget.appFacade,
          ),
        ),
      );
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      _isCommentsLoading = true; // Mostrar el spinner de carga
    });

    // Cargar los comentarios
    await widget.appFacade.fetchCommentsByArtworkId(_artworkId!);

    // Detener el spinner y actualizar el estado
    setState(() {
      _isCommentsLoading = false;
    });
  }

  Future<void> _startTTS(String text) async {
    if (_isPlaying) {
      await flutterTts.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await flutterTts.speak(text);
      setState(() {
        _isPlaying = true;
      });

      // Agregar documento a Firestore cuando el TTS empieza (Acción: 1)
      await _firestoreService.addDocument('BQ32', {
        'Acción': 1,
        'Fecha': DateTime.now(),
      });
    }
  }

  Future<void> _stopTTS() async {
    await flutterTts.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  // Método para obtener el nombre de usuario por ID
  Future<String?> _getUsername(int userId) async {
    return await widget.appFacade.getUsername(userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: "ARTWORK", showProfileIcon: true, showBackArrow: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : BlocBuilder<ArtworkCubit, ArtworkState>(
        bloc: widget.appFacade.artworkCubit,
        builder: (context, state) {
          if (state is ArtworkLoading) {
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
                              onPressed: _onLikePressed,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            onPressed: () async {
                              if (artist != null) {
                                await Navigator.pushNamed(
                                  context,
                                  Routes.artist,
                                  arguments: {'artist': artist},
                                );
                                if (_artworkId != null) {
                                  final favorites = await widget.appFacade.fetchFavorites();
                                  _checkIfLiked(favorites);
                                  widget.appFacade.fetchArtworkAndRelatedEntities(_artworkId!);
                                }
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
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
                        child: Text(
                          artwork?.interpretation ?? "Unknown Interpretation",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
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
                      if (_isForumOpen) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _commentController,
                                cursorColor: Colors.black, // Color del cursor
                                decoration: InputDecoration(
                                  filled: true, // Asegura que el fondo del campo esté relleno
                                  fillColor: Colors.grey[200], // Color de fondo del campo
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black), // Color del borde cuando está seleccionado
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black), // Color del borde cuando no está seleccionado
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  hintText: 'Write your comment...',
                                ),
                                style: TextStyle(color: Colors.black), // Asegura que el texto sea visible
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 150,
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black, // Color de fondo del botón
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _submitComment,
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(color: Colors.white, fontSize: 14), // Color del texto del botón
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Mostrar un spinner si los comentarios están cargando
                              _isCommentsLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.comments?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final comment = state.comments![index];
                                  return FutureBuilder<String?>(
                                    future: _getUsername(comment.user),
                                    builder: (context, snapshot) {
                                      final username = snapshot.data ?? 'Unknown User';
                                      final usernameColor = theme.colorScheme.secondary;
                                      return ListTile(
                                        title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              username,
                                              style: TextStyle(
                                                color: usernameColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(comment.content),
                                          ],
                                        ),
                                      );
                                    },
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
