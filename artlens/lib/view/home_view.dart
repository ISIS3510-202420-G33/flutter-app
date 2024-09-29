import 'package:flutter/material.dart';
import '../routes.dart';
import '../widgets/custom_button.dart';
import 'map_view.dart';
import 'package:artlens/widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';

class HomeView extends StatefulWidget {
  static final HomeView _instance = HomeView._internal();

  HomeView._internal();

  factory HomeView() {
    return _instance;
  }

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // Define a function to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        // No need to navigate if already on Home
      } else if (index == 1) {
        Navigator.pushNamed(
          context,
          Routes.camera,
        ).then((_) {
          // When returning to HomeView, reset the selected index to 0
          setState(() {
            _selectedIndex = 0;
          });
        });
      } else if (index == 2) {
        // Navigate to Trending page (replace with real view if available)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the theme

    return Scaffold(
      appBar: CustomAppBar(title: "HOME", showProfileIcon: true, showBackArrow: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Content inside a LayoutBuilder to check if scrolling is needed
          return RawScrollbar(
            thumbVisibility: true, // Scrollbar will appear when needed
            thickness: 6.0,
            radius: const Radius.circular(15),
            thumbColor: theme.colorScheme.secondary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: constraints.maxHeight < 600
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(), // Allow scroll only if necessary
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Welcome to ArtLens!",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge, // Using displayLarge from the theme
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Museums in your city",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge, // Using bodyLarge from the theme
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Three custom buttons using the reusable widget
                      CustomButton(
                        label: "View all museums",
                        onPressed: () {
                          // Define button action
                        },
                      ),
                      CustomButton(
                        label: "View Map",
                        onPressed: () {
                          // Navigate to the map view
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MapView()),
                          );
                        },
                      ),
                      CustomButton(
                        label: "View Artists",
                        onPressed: () {
                          // Define button action
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
