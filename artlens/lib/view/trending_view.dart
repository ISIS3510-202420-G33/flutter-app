import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/connectivity_cubit.dart';
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
  bool isOnline = true;
  bool isFetched = false;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    widget.appFacade.fetchSpotlightArtworks();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult[0] != ConnectivityResult.none;
    if (isOnline) {
      isFetched = true;
      widget.appFacade.fetchSpotlightArtworks();
      widget.appFacade.fetchRecommendationsByUserId();
    } else {
      if (isFetched) {
        setState(() {
          isOnline;
        });
      } else {
        widget.appFacade.fetchSpotlightArtworks();
        widget.appFacade.fetchRecommendationsByUserId(); // Fail gracefully
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

      if (!isFetched) {
        Future.delayed(const Duration(seconds: 5), () {
          isFetched = true;
          widget.appFacade.fetchSpotlightArtworks();
          widget.appFacade.fetchRecommendationsByUserId();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.appFacade.fetchRecommendationsByUserId();
  }

  // Handle navigation between views in the bottom navigation bar
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
          BlocListener<ConnectivityCubit, ConnectivityState>(
            listener: _handleConnectivityChange,
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<Artwork> spotlightArtworks = [];
                      List<Artwork> recommendationsByUserId = [];

                      if (spotlightState is SpotlightArtworksLoaded) {
                        spotlightArtworks = spotlightState.spotlightArtworks;
                      }

                      if (recommendationsState is RecommendationsLoaded) {
                        recommendationsByUserId = recommendationsState.recommendationsByUserId;
                      }

                      return ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          children: [
                            // Section for Promoted Artworks
                            const Text(
                              'Spotlight',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            if (spotlightArtworks.isNotEmpty) ...[
                              ...spotlightArtworks.map((artwork) => _buildArtworkTile(artwork)),
                              const SizedBox(height: 20),
                            ] else if (!isOnline) ...[
                              const Center(
                                child: Text(
                                  "No internet connection. Waiting for connection...",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ] else ...[
                              const Center(child: Text('No spotlight artworks available.')),
                            ],

                            // Section for User-based Recommendations
                            const Text(
                              'Based on your favorites',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            if (recommendationsByUserId.isNotEmpty) ...[
                              ...recommendationsByUserId.map((artwork) => _buildArtworkTile(artwork)),
                            ] else if (!isOnline) ...[
                              const Center(
                                child: Text(
                                  "No internet connection. Waiting for connection...",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else ...[
                              const Center(child: Text('No recommendations available.')),
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
    final localImagePath = artwork.localImagePath;
    final localImageExists = localImagePath != null && File(localImagePath).existsSync();

    return GestureDetector(
      onTap: isOnline
          ? () {
        Navigator.pushNamed(
          context,
          Routes.artwork,
          arguments: {'id': artwork.id},
        );
      }
          : null,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Check if there's a local image, otherwise use the network image
              localImageExists
                  ? Image.file(
                File(localImagePath!),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
                  : Image.network(
                artwork.image,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading network image for ${artwork.name}");
                  return Icon(Icons.image_not_supported, size: 100);
                },
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
