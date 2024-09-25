import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../routes.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ArtworkView extends StatefulWidget {
  final int id;

  const ArtworkView({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _ArtworkViewState createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  int _selectedIndex = 1;
  bool _isLiked = false;

  // Define a function to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false
        );
      } else if (index == 1) {
        Navigator.pushNamed(
          context,
          Routes.camera,
        );
      } else if (index == 2) {
        // Navigate to Trending page (replace with real view if available)
      }
    });
  }

  // Function to toggle the like status
  void _onLikePressed() {
    setState(() {
      _isLiked = !_isLiked; // Toggle the like status
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme

    return Scaffold(
      appBar: CustomAppBar(title: "ARTWORK"), // Usage of custom AppBar
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding for overall content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adjusted Row containing title and like button
            Padding(
              padding: const EdgeInsets.only(top: 32.0, left: 80.0), // Moves the row down
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32.0), // Moves title to the right
                      child: Center(
                        child: Text(
                          'La Gioconda',
                          style: theme.textTheme.headlineMedium, // Use a larger size for the title
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _isLiked ? theme.colorScheme.secondary : Colors.black, // Toggle background color
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/star-solid.svg',
                          color: Colors.white, // White icon
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                    onPressed: _onLikePressed, // Toggle like status
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Artwork Image with fixed width
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 280, maxHeight: 350), // Adjust maxWidth and maxHeight as needed
                child: Image.network(
                  'https://www.arteworld.it/wp-content/uploads/2016/02/Gioconda-San-Pietroburgo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Basic Description of the Artwork with adjusted padding
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top:16.0), // Adjust padding to move text to the right
              child: Text(
                "Artist: Leonardo da Vinci\n"
                    "Creation Date: 1505\n"
                    "Technique: Oil painting on poplar wood\n"
                    "Dimensions: 77 cm × 53 cm (30 in × 21 in)\n"
                    "Current Location: Louvre Museum, Paris, France",
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Play audio button with description
            // Play audio button with description
            Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/headphones-solid.svg',
                    color: Colors.black, // Black icon
                    height: 40,
                  ),
                  padding: EdgeInsets.only(left: 20.0), // Add padding between icon and text
                  onPressed: () {
                    // Action to start audio narration
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0), // Add padding between icon and text
                  child: Text(
                    "Click the icon to start the audio narration.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold, // Make the text bold
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Custom button to view more artist details
            // Button to view more artist details
            Padding(
              padding: const EdgeInsets.only(left: 28.0), // Move the button to the right
              child: SizedBox(
                width: 328, // Width of the button
                height: 39, // Height of the button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Curvature of the corners
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.artist,
                    );
                  },
                  child: Text(
                    "View Artist Details",
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 18, // Increase font size
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ), // Usage of custom BottomNavBar
    );
  }
}
