import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../views/camera_view.dart';  // Correct relative path


class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  Widget _buildIcon(String assetName, {double size = 24}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SvgPicture.asset(
        assetName,
        color: Colors.white,
        height: size,
        width: size,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) { // Camera Tab is at index 1
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraPreviewScreen()), // Push CameraPreviewScreen
      );
    } else {
      widget.onItemTapped(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildIcon('assets/images/house-solid.svg'),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('assets/images/camera-solid.svg'),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('assets/images/fire-solid.svg'),
          label: 'Trending',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.secondary, // Theme's secondary color for selected item
      unselectedItemColor: Colors.black, // Black for unselected items
      onTap: _onItemTapped, // Use the updated onTap function
    );
  }
}
