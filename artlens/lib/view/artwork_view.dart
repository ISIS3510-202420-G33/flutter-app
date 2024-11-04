import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../model/firestore_service.dart';
import '../routes.dart';
import '../view_model/comments_cubit.dart';
import '../view_model/facade.dart';
import '../view_model/artwork_cubit.dart';
import '../view_model/isFavorite_cubit.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _documentId;
  String? _artworkName;
  int _selectedIndex = 1;
  bool _isForumOpen = false;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isFavorited = false;
  bool? _isSpotlight;
  DateTime? _entryTime;
  bool _isFavoritedInitialized = false;

  final TextEditingController _commentController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _artworkId = widget.id;
    _entryTime = DateTime.now();

    // Configura los parámetros iniciales de TTS
    flutterTts.setLanguage('en-US');
    flutterTts.setSpeechRate(0.5);

    // Configurar el completion handler cuando el TTS finaliza
    flutterTts.setCompletionHandler(() async {
      setState(() {
        _isPlaying = false;
      });

      if (_documentId != null) {
        // Eliminar el documento con Acción 1
        await _firestoreService.deleteDocument('BQ32', _documentId!);

        // Agregar documento con Acción 2
        await _firestoreService.addDocument('BQ32', {
          'Acción': 2,
          'Fecha': DateTime.now(),
        });

        // Limpiar el documentId después de eliminarlo
        _documentId = null;
      }
    });

    _initializeArtwork();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registrar la vista para recibir notificaciones de rutas con RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void _initializeArtwork() {
    setState(() {
      _isLoading = true;
    });
    widget.appFacade.fetchArtworkAndRelatedEntities(widget.id);
    widget.appFacade.fetchCommentsByArtworkId(widget.id);
    widget.appFacade.isArtworkLiked(widget.id);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _sendArtworkExitData();
    routeObserver.unsubscribe(this);
    flutterTts.stop();
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
      } else if (index == 2) {
        Navigator.pushNamed(context, Routes.trending);
      }
    });
  }

  void _onLikePressed() async {
    try {
      if (_isFavorited) {
        setState(() {
          _isFavorited = false;
        });
        widget.appFacade.removeFavorite(_artworkId!);
      } else {
        setState(() {
          _isFavorited = true;
        });
        widget.appFacade.addFavorite(_artworkId!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like status')),
      );
    }
  }

  void openForum() async {
    DateTime date = DateTime.now();
    int action = 1;
    final prefs = await SharedPreferences.getInstance();
    final username =  prefs.getString('userName');
    await _firestoreService.addDocument('BQ31', {
      'Usuario': username,
      'Fecha': date,
      'Accion': action,
    });
  }

  void _submitComment() async {
    if (_commentController.text.isNotEmpty) {
      String content = _commentController.text;
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      DateTime date2 = DateTime.now();

      int action = 2;
      final prefs = await SharedPreferences.getInstance();
      final username =  prefs.getString('userName');
      await _firestoreService.addDocument('BQ31', {
        'Usuario': username,
        'Fecha': date2,
        'Accion': action,
      });

      widget.appFacade.postComment(content, date, _artworkId!);

      _commentController.clear();
    }
  }

  Future<void> _startTTS(String text) async {
    if (_isPlaying) {
      await flutterTts.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      // Inicia el TTS
      await flutterTts.speak(text);
      setState(() {
        _isPlaying = true;
      });

      // Agregar documento a Firestore cuando el TTS empieza (Acción: 1)
      String docId = await _firestoreService.addDocument('BQ32', {
        'Acción': 1,
        'Fecha': DateTime.now(),
      });

      // Guardar el documentId
      _documentId = docId;
    }
  }

  Future<void> _stopTTS() async {
    await flutterTts.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _sendArtworkExitData() async {
    if (_entryTime != null) {
      final exitTime = DateTime.now();
      final timeSpent = exitTime.difference(_entryTime!).inSeconds;

      // Send data to Firestore
      await _firestoreService.addDocument('BQ42', {
        'artworkId': _artworkName,
        'isSpotlight': _isSpotlight,
        'timeSpentInView': timeSpent,
        'isFavorited': _isFavorited,
        'exitTime': exitTime,
      });
    }
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

            _isSpotlight = artwork?.isSpotlight;
            _artworkName = artwork?.name;

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
                            if (widget.appFacade.isLoggedIn())
                              BlocBuilder<IsFavoriteCubit, IsFavoriteState>(
                                bloc: widget.appFacade.isFavoriteCubit,
                                builder: (context, likeState) {
                                  if (likeState is IsLikedLoaded && !_isFavoritedInitialized) {
                                    _isFavorited = likeState.isLiked;
                                    _isFavoritedInitialized = true;
                                  }
                                  return IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: _isFavorited
                                            ? theme.colorScheme.secondary
                                            : Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(Icons.star, color: Colors.white),
                                      ),
                                    ),
                                    onPressed: () {
                                      _onLikePressed();
                                    },
                                  );
                                },
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
                            onPressed: () {
                              openForum();
                              setState(() {
                                _isForumOpen = !_isForumOpen;
                              });
                            },
                            child: Text(
                              _isForumOpen ? "Close Forum" : "Open Forum",
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      if (_isForumOpen)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: BlocBuilder<CommentsCubit, CommentsState>(
                            bloc: widget.appFacade.commentsCubit,
                            builder: (context, commentState) {
                              if (commentState is CommentsLoading) {
                                return Center(child: CircularProgressIndicator());
                              } else if (commentState is CommentsLoaded) {
                                final comments = commentState.comments ?? [];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.appFacade.isLoggedIn()) ...[
                                      TextField(
                                        controller: _commentController,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          hintText: 'Write your comment...',
                                        ),
                                        style: TextStyle(color: Colors.black),
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
                                    ],
                                    const SizedBox(height: 16),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        final comment = comments[index];
                                        final username = commentState.username ?? 'Unknown User';
                                        final usernameColor = theme.colorScheme.secondary;

                                        return ListTile(
                                          title: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '$username: ',
                                                  style: TextStyle(
                                                    color: usernameColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: comment.content,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              } else if (commentState is CommentsError) {
                                return Center(child: Text('Error: ${commentState.message}'));
                              } else {
                                return Center(child: const Text("No comments available."));
                              }
                            },
                          ),
                        ),
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
