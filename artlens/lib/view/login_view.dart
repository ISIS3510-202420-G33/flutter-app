import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/facade.dart';

class LogInView extends StatefulWidget {
  final AppFacade appFacade;

  const LogInView({
    Key? key,
    required this.appFacade,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LogInView> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Log In",
        showProfileIcon: false,
        showBackArrow: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isScrollable = constraints.maxHeight < 600;

          return RawScrollbar(
            thumbVisibility: isScrollable,
            thickness: 6.0,
            radius: const Radius.circular(15),
            thumbColor: theme.colorScheme.secondary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: isScrollable
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.1),
                      // User Icon
                      Container(
                        padding: const EdgeInsets.all(25.0),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: Colors.white, size: 70),
                      ),
                      SizedBox(height: 32),
                      // Username input
                      TextField(
                        controller: _userNameController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelText: 'Username',
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
                      // Password input
                      TextField(
                        controller: _passwordController,
                        cursorColor: Colors.black,
                        obscureText: true,
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
                      // Log In button
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
                          onPressed: () async {
                            print('Presionaste el botón de Log In');
                            await widget.appFacade.authenticateUser(
                              _userNameController.text,
                              _passwordController.text,
                            );

                            if (widget.appFacade.isLoggedIn()) {
                              // Show success SnackBar with orange color
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: theme.colorScheme.secondary,  // Naranja
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        'Login successful!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // Navigate to home immediately
                              Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
                            } else {
                              // Show error SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Row(
                                    children: [
                                      Icon(Icons.error, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        'Invalid username or password.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Text('Log In', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: Text('Forgot password?', style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.1),
                      SizedBox(
                        width: 250,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context,
                                Routes.signUp
                            );
                          },
                          child: Text('Create new account', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
