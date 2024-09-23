import 'package:flutter/material.dart';
import '../widgets/custom_button.dart'; // Import the reusable custom button widget
import 'map_view.dart';
import 'package:artlens/widgets/custom_bottom_nav_bar.dart';
import 'login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // Define a function to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation based on index
      if (index == 0) {

      } else if (index == 1) {
        // Navigate to Camera page
      } else if (index == 2) {
        // Navigate to Trending page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the theme

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor, // White background from the theme
        title: Text(
          "HOME",
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(), // Reutiliza la instancia singleton de LoginPage
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                // Navegar a la vista del mapa
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
