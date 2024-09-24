import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavBar({required this.selectedIndex, required this.onItemTapped});

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
      currentIndex: selectedIndex, // Reflect the selected index
      selectedItemColor: Theme.of(context).colorScheme.secondary, // Theme's secondary color for selected item
      unselectedItemColor: Colors.black, // Black for unselected items
      onTap: (index) => onItemTapped(index), // Delegate tap handling to parent
    );
  }
}
