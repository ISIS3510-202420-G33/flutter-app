import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_app_bar.dart';
import 'sign_up_view.dart';  // Importa la vista de SignUpPage

class LoginPage extends StatelessWidget {
  static final LoginPage _instance = LoginPage._internal();

  LoginPage._internal();

  factory LoginPage() {
    return _instance;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para obtener el tamaño de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: "LOG IN", showProfileIcon: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 32),
            // Ícono de usuario dentro de un círculo negro aún más prominente
            Container(
              padding: const EdgeInsets.all(25.0), // Aumentamos más el padding para más negro
              decoration: const BoxDecoration(
                color: Colors.black, // Fondo negro
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/images/user-solid.svg',
                height: 70, // Reduce ligeramente el tamaño del ícono para más fondo negro
                width: 70,
                color: Colors.white, // Ícono blanco
              ),
            ),
            SizedBox(height: 32),

            // Campos de Texto
            TextField(
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Username or email',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Botón de inicio de sesión
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  // Acción de inicio de sesión
                },
                child: Text('Log In', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16),

            // Forgot password
            TextButton(
              onPressed: () {
                // Acción de "Forgot Password"
              },
              child: Text('Forgot password?', style: TextStyle(color: Colors.black)),
            ),

            // Espacio dinámico basado en el tamaño de la pantalla
            SizedBox(height: screenHeight * 0.25), // Ajusta el porcentaje según sea necesario

            // Botón de Crear Cuenta
            SizedBox(
              width: 250,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  // Navegación a la vista de Sign Up
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text('Create new account', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
