import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../view/login_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileIcon;
  final bool showBackArrow;

  CustomAppBar({
    required this.title,
    this.showProfileIcon = true,
    this.showBackArrow = true,
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
          offset: const Offset(0, 6),
          child: AppBar(
            backgroundColor: Colors.white,
            leading: showBackArrow
                ? Padding(
              padding: const EdgeInsets.only(left: 16.0),
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
            centerTitle: true,
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}
