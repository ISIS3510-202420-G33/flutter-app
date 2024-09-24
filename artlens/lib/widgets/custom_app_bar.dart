import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../views/login_view.dart';  // Asegúrate de importar la vista de Login

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileIcon;  // Controla si se muestra el ícono de perfil
  final bool showBackArrow;    // Nuevo parámetro para controlar si se muestra la flecha

  CustomAppBar({
    required this.title,
    this.showProfileIcon = true,
    this.showBackArrow = true,  // Por defecto muestra la flecha
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Línea superior
        Container(
          height: 0.5, // Espesor de la línea
          color: Colors.black.withOpacity(0.1), // Línea casi transparente
        ),
        // AppBar
        Transform.translate(
          offset: const Offset(0, 6), // Ajusta el AppBar ligeramente hacia abajo
          child: AppBar(
            backgroundColor: Colors.white,
            leading: showBackArrow
                ? Padding(
              padding: const EdgeInsets.only(left: 16.0), // Mueve la flecha hacia la derecha
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    print('No screen to pop back to');
                  }
                },
              ),
            )
                : null, // No muestra el ícono de flecha si `showBackArrow` es `false`
            centerTitle: true, // Centra el título
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800, // Extra bold para el título
              ), // Aplica el estilo global del tema
            ),
            actions: showProfileIcon
                ? [
              Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.black, // Fondo negro
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/user-solid.svg',
                        color: Colors.white, // Ícono blanco
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Navegar a la vista de Login
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Navegar a LoginPage
                    );
                  },
                ),
              ),
            ]
                : [], // No muestra el ícono de perfil si `showProfileIcon` es `false`
          ),
        ),
        // Línea inferior
        Container(
          height: 0.5, // Espesor de la línea
          color: Colors.black.withOpacity(0.1), // Línea casi transparente
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12); // Ajustar el tamaño total para incluir las líneas
}
