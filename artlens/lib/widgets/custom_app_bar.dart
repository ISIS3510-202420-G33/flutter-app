import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        Transform.translate(
          offset: Offset(0, 8),
          child: IconButton(
            padding: const EdgeInsets.only(right: 32.0),
            icon: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black, // Círculo negro
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/user-solid.svg',
                  color: Colors.white, // Logo blanco
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
