import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_app_bar.dart';  // Asegúrate de importar la CustomAppBar

class SignUpPage extends StatelessWidget {
  static final SignUpPage _instance = SignUpPage._internal();

  SignUpPage._internal();

  factory SignUpPage() {
    return _instance;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para obtener el tamaño de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: "SIGN UP", showProfileIcon: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.1),

            // Campos de Texto
            TextField(
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Email address',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(25),
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
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Confirm password',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Botón de Sign Up
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
                  // Acción de registro
                },
                child: Text('Sign Up', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16),

            // Espacio dinámico basado en el tamaño de la pantalla
            SizedBox(height: screenHeight * 0.125),  // Ajusta el porcentaje según sea necesario

            // Botón "Already have an account?"
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
                  Navigator.pop(context);  // Vuelve a la vista de Login
                },
                child: Text('Already have an account?', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 32),  // Espacio final si es necesario
          ],
        ),
      ),
    );
  }
}
