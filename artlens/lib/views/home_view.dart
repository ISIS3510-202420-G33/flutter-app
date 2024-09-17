import 'package:flutter/material.dart';
import '../widgets/custom_button.dart'; // Import the reusable custom button widget

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
        // Stay on Home page
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
              // Navigate to profile or any other action
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
                // Define button action
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Trending',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the current item
        selectedItemColor: theme.colorScheme.secondary, // Use accent color for selected item
        unselectedItemColor: theme.colorScheme.onPrimary, // Use black for unselected items
        onTap: _onItemTapped, // Handle tap on the items
      ),
    );
  }
}
