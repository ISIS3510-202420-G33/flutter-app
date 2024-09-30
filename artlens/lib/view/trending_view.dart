import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view_model/facade.dart';
import '../view_model/analytic_engine_cubit.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../entities/artwork.dart';
import '../routes.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class TrendingView extends StatefulWidget {
  final AppFacade appFacade;

  const TrendingView({
    Key? key,
    required this.appFacade,
  }) : super(key: key);

  @override
  _TrendingViewState createState() => _TrendingViewState();
}

class _TrendingViewState extends State<TrendingView> {
  int? userId;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Cargar el userId desde SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });

    if (userId != null) {
      widget.appFacade.fetchRecommendationsByUserId(userId!);
    }
  }

  // Manejar la navegación entre las vistas del bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else if (index == 1) {
        Navigator.pushNamed(context, Routes.camera);
      } else if (index == 2) {
        // Ya estamos en Trending
      }
    });
  }

  // Método para truncar texto largo en la descripción de la obra
  String _truncateText(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return '${words.sublist(0, maxWords).join(' ')}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "TRENDING", showProfileIcon: false),
      body: BlocBuilder<AnalyticEngineCubit, AnalyticEngineState>(
        bloc: widget.appFacade.analyticEngineCubit,
        builder: (context, state) {
          if (state is AnalyticEngineLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AnalyticEngineLoaded) {
            if (state.recommendationsByUserId.isEmpty) {
              return Center(child: Text('No trending artworks found.'));
            }

            return ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: RawScrollbar(
                thumbVisibility: true,
                thickness: 6.0,
                radius: const Radius.circular(15),
                thumbColor: Theme.of(context).colorScheme.secondary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  itemCount: state.recommendationsByUserId.length,
                  itemBuilder: (context, index) {
                    final Artwork artwork = state.recommendationsByUserId[index];

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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Imagen centrada verticalmente
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
                                    // Truncar la descripción si es demasiado larga
                                    Text(
                                      _truncateText(artwork.interpretation, 20), // Limitar a 20 palabras
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
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
          } else if (state is AnalyticEngineError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: const Text('No trending artworks found.'));
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
