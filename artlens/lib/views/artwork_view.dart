import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArtworkView extends StatefulWidget {
  final String artworkName;
  final String imageUrl;

  const ArtworkView({
    Key? key,
    required this.artworkName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _ArtworkViewState createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  int _selectedIndex = 0;
  Color _iconColor = Colors.grey; // Default color of the icon

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navegación basada en el índice
    });
  }

  // Función para alternar el color del icono
  void _onLogoPressed() {
    setState(() {
      _iconColor = (_iconColor == Colors.grey) ? Colors.red : Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Accede al tema actual

    return Scaffold(
      appBar: CustomAppBar(title: "ARTWORK"), // Uso del AppBar personalizado
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la obra
            Center(
              child: Text(
                widget.artworkName,
                style: theme.textTheme.headlineMedium, // Usa un tamaño más pequeño para el título
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Imagen de la obra con el botón de favorito
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite),
                  color: _iconColor, // Establece el color del icono
                  onPressed: _onLogoPressed, // Alterna el color al hacer clic
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descripción básica de la obra
            Text(
              "Artist: Leonardo da Vinci\n"
                  "Creation Date: 1505\n"
                  "Technique: Oil painting on poplar wood\n"
                  "Dimensions: 77 cm × 53 cm (30 in × 21 in)\n"
                  "Current Location: Louvre Museum, Paris, France",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Botón para reproducir audio con descripción
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    // Acción para iniciar la narración de audio
                  },
                ),
                const Text("Click the icon to start the audio narration."),
              ],
            ),
            const SizedBox(height: 16),

            // Botón personalizado para ver más detalles del artista
            ElevatedButton(
              onPressed: () {
                // Acción para ver detalles del artista
              },
              child: Text("View Artist Details"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ), // Uso del BottomNavBar personalizado
    );
  }
}
