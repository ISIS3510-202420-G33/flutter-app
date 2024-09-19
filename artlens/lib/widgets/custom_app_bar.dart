import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

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
          offset: Offset(0, 6), // Ajusta el AppBar ligeramente hacia abajo
          child: AppBar(
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0), // Mueve la flecha hacia la derecha
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            centerTitle: true, // Centra el título
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800, // Extra bold para el título
              ), // Aplica el estilo global del tema
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 32.0), // Alinea el ícono con el título
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
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
                    // Acción para navegar al perfil de usuario
                  },
                ),
              ),
            ],
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
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 12); // Ajustar el tamaño total para incluir las líneas
}
