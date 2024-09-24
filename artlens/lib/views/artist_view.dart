import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart'; // Asegúrate de importar tu CustomBottomNavBar

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class ArtistView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lista de obras favoritas simuladas
    final List<Map<String, String>> favorites = [
      {
        'title': 'Nighthawks',
        'description': '"Nighthawks" is a painting by American artist Edward Hopper, depicting four people in an urban diner at night.',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Nighthawks_by_Edward_Hopper_1942.jpg/800px-Nighthawks_by_Edward_Hopper_1942.jpg',
      },
      {
        'title': 'The scream',
        'description': '"The Scream" is the title of four paintings by Norwegian artist Edvard Munch. The most famous version is located at the National Gallery of Norway.',
        'imageUrl': 'https://www.edvardmunch.org/assets/img/thumbs/the-scream.jpg',
      },
      // Más obras para probar el scroll
      {
        'title': 'Starry Night',
        'description': 'A famous painting by Vincent van Gogh, depicting a swirling night sky over a quiet town.',
        'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDuXRsUi_vW5fZKRvlB41OoexUjhckdOrURQ&s'
      },
      {
        'title': 'Mona Lisa',
        'description': 'A portrait painting by Leonardo da Vinci, one of the most famous paintings in the world.',
        'imageUrl': 'https://t1.gstatic.com/licensed-image?q=tbn:ANd9GcQsu7yYuRPXNK9eHHSFD2tUYO4stQDb1Ez8vjqGERfs9xqYLLnY_y6lQkPFZa-44cqn',
      },
      {
        'title': 'The Persistence of Memory',
        'description': 'A surreal painting by Salvador Dalí, showcasing melting clocks in a desert landscape.',
        'imageUrl': 'https://www.singulart.com/images/artworks/v2/cropped/54718/alts/alt_2047336_1be4af8aaf321cda716f08bd62d9ba3e.jpeg',
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(title: "FAVORITES", showProfileIcon: false),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(), // Usamos la clase personalizada para eliminar el glow
        child: RawScrollbar(
          thumbVisibility: true, // La barra de desplazamiento siempre está visible
          thickness: 6.0, // Grosor de la barra de desplazamiento
          radius: const Radius.circular(15), // Curvatura de la barra
          thumbColor: Theme.of(context).colorScheme.secondary, // Aquí aplicamos el color secundario
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final artwork = favorites[index];
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen de la obra
                      Image.network(
                        artwork['imageUrl']!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      // Título y descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artwork['title']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              artwork['description']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // Botón de eliminación
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Acción para eliminar la obra de la lista de favoritos
                        },
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, height: 32), // Separador entre las obras
                ],
              );
            },
          ),
        ),
      ),
      // Uso de tu CustomBottomNavBar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2, // Indica la pestaña actual
        onItemTapped: (index) {
          // Manejar la navegación cuando se toquen los elementos de la barra
        },
      ),
    );
  }
}
