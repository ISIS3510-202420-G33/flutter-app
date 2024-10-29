import 'package:flutter/material.dart';
import '../routes.dart';
import '../widgets/custom_button.dart';
import 'package:artlens/widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/fake_search_bar.dart'; // Importar el nuevo widget

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
        );
      } else if (index == 2) {
        Navigator.pushNamed(
          context,
          Routes.trending,
        );
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
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: FakeSearchBar(
                          onTap: () {
                            //Navigator.pushNamed(context, Routes.search); // Navegar a la vista de búsqueda
                          },
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
                      CustomButton(
                        label: "View all museums",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.museums,
                          );
                        },
                      ),
                      CustomButton(
                        label: "View Map",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.map,
                          );
                        },
                      ),
                      CustomButton(
                        label: "View Artists",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.artists,
                          );
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
