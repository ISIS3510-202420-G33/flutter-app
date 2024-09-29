import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/login_view.dart';
import '../view_model/auth_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileIcon;
  final bool showBackArrow;

  CustomAppBar({
    required this.title,
    this.showProfileIcon = true,
    this.showBackArrow = true,
  });

  Future<String?> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>(); // Access AuthCubit to check authentication state

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
                  onPressed: () async {
                    if (authCubit.isLoggedIn()) {
                      // Fetch userName from SharedPreferences
                      String? userName = await _getUserName();

                      // Show a custom dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            contentPadding: const EdgeInsets.all(16.0),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Hi, $userName!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Divider(),
                                ListTile(
                                  leading: Icon(Icons.favorite),
                                  title: Text('View Favorites'),
                                  onTap: () {
                                    Navigator.pop(context); // Close the dialog
                                    Navigator.pushNamed(context, '/favorites');
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.logout),
                                  title: Text('Log Out'),
                                  onTap: () {
                                    Navigator.pop(context); // Close the dialog
                                    authCubit.logOut();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      // Navigate to LoginPage if the user is not logged in
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
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
