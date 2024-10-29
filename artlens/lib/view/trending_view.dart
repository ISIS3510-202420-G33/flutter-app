import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view_model/facade.dart';
import '../view_model/spotlight_artworks_cubit.dart';
import '../view_model/recommendations_cubit.dart';
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
    widget.appFacade.fetchSpotlightArtworks();
    _loadUserId();
  }

  // Load userId from SharedPreferences and fetch recommendations
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });

    if (userId != null) {
      widget.appFacade.fetchRecommendationsByUserId(userId!);
    } else {
      widget.appFacade.clearRecommendations();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if the user is logged in each time the view's state changes
    _loadUserId();
  }

  // Handle navigation between views in the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else if (index == 1) {
        Navigator.pushNamed(context, Routes.camera);
      } else if (index == 2) {
        // Already in Trending
      }
    });
  }

  // Helper method to truncate long text in the artwork description
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<SpotlightArtworksCubit, SpotlightArtworksState>(
            bloc: widget.appFacade.spotlightArtworksCubit,
            listener: (context, state) {
              // Handle any specific actions or states related to PromotedArtworks
            },
          ),
          BlocListener<RecommendationsCubit, RecommendationsState>(
            bloc: widget.appFacade.recommendationsCubit,
            listener: (context, state) {
              // Handle any specific actions or states related to Recommendations
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<SpotlightArtworksCubit, SpotlightArtworksState>(
                bloc: widget.appFacade.spotlightArtworksCubit,
                builder: (context, spotlightState) {
                  return BlocBuilder<RecommendationsCubit, RecommendationsState>(
                    bloc: widget.appFacade.recommendationsCubit,
                    builder: (context, recommendationsState) {
                      if (spotlightState is SpotlightArtworksLoading ||
                          recommendationsState is RecommendationsLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      List<Artwork> spotlightArtworks = [];
                      List<Artwork> recommendationsByUserId = [];

                      if (spotlightState is SpotlightArtworksLoaded) {
                        spotlightArtworks = spotlightState.spotlightArtworks;
                      }

                      if (recommendationsState is RecommendationsLoaded) {
                        recommendationsByUserId = recommendationsState.recommendationsByUserId;
                      }

                      if (spotlightArtworks.isEmpty && recommendationsByUserId.isEmpty) {
                        return Center(child: Text('No trending or promoted artworks found.'));
                      }

                      return ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          children: [
                            // Section for Promoted Artworks
                            if (spotlightArtworks.isNotEmpty) ...[
                              Text(
                                'Spotlight',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              ...spotlightArtworks.map((artwork) => _buildArtworkTile(artwork)).toList(),
                              const SizedBox(height: 20),
                            ],

                            // Section for User-based Recommendations
                            if (recommendationsByUserId.isNotEmpty) ...[
                              Text(
                                'Based on your favoritess',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              ...recommendationsByUserId.map((artwork) => _buildArtworkTile(artwork)).toList(),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Helper method to build artwork tile
  Widget _buildArtworkTile(Artwork artwork) {
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
                    Text(
                      _truncateText(artwork.interpretation, 20),
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
  }
}
