import 'package:flutter/material.dart';
import '../routes.dart'; // Asegúrate de que tengas la ruta configurada

class FakeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const FakeSearchBar({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.searchResults, arguments: ""); // Argumento vacío por defecto
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Search for artwork, artist, or museum",
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
            Icon(Icons.search, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
