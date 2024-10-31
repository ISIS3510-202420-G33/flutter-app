import 'package:flutter/material.dart';
import '../view_model/facade.dart';
import '../widgets/custom_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/connectivity_cubit.dart';

class SignUpView extends StatefulWidget {
  final AppFacade appFacade;

  const SignUpView({
    Key? key,
    required this.appFacade,
  }) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Limpiar los controladores cuando el widget sea destruido
  @override
  void dispose() {
    _emailController.clear();
    _userNameController.clear();
    _nameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: "SIGN UP", showProfileIcon: false),
      body: BlocListener<ConnectivityCubit, ConnectivityState>(
        listener: (context, state) {
          if (state is ConnectivityOffline) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No internet connection. Please check your network.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),

              // Campos de Texto
              TextField(
                controller: _emailController,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
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
                controller: _userNameController,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
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
                controller: _nameController,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
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
                controller: _passwordController,
                obscureText: true,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
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
                controller: _confirmPasswordController,
                obscureText: true,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
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
              BlocBuilder<ConnectivityCubit, ConnectivityState>(
                builder: (context, state) {
                  return SizedBox(
                    width: 200,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: state is ConnectivityOffline ? null : () async {
                        // Lógica para registrar al usuario
                        String email = _emailController.text.trim();
                        String userName = _userNameController.text.trim();
                        String name = _nameController.text.trim();
                        String password = _passwordController.text;
                        String confirmPassword = _confirmPasswordController.text;

                        if (!_isValidEmail(email)) {
                          _showErrorSnackBar(context, 'Please enter a valid email.');
                          return;
                        }
                        if (!_isValidUsername(userName)) {
                          _showErrorSnackBar(context, 'Username cannot have spaces or special characters.');
                          return;
                        }
                        if (name.isEmpty) {
                          _showErrorSnackBar(context, 'Please enter your name.');
                          return;
                        }
                        if (!_isValidPassword(password)) {
                          _showErrorSnackBar(context, 'Password must be at least 8 characters, contain a number, a capital letter, and a special character.');
                          return;
                        }
                        if (password != confirmPassword) {
                          _showErrorSnackBar(context, 'Passwords do not match.');
                          return;
                        }

                        String? result = await widget.appFacade.registerUser(name, userName, email, password);

                        if (result == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: theme.colorScheme.secondary,
                              content: Text('Registration successful! Logging in...'),
                            ),
                          );

                          await widget.appFacade.authenticateUser(userName, password);

                          if (widget.appFacade.isLoggedIn()) {
                            Navigator.pushNamed(context, '/');
                          } else {
                            _showErrorSnackBar(context, 'Error logging in after registration.');
                          }
                        } else if (result == 'error') {
                          _showErrorSnackBar(context, 'User or email already exists.');
                        } else {
                          _showErrorSnackBar(context, 'An unexpected error occurred.');
                        }
                      },
                      child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),

              // Espacio dinámico basado en el tamaño de la pantalla
              SizedBox(height: screenHeight * 0.125),

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
                    Navigator.pop(context);
                  },
                  child: Text('Already have an account?', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Método para mostrar un SnackBar con errores
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[!@#\$&*~]').hasMatch(password);
  }
}
