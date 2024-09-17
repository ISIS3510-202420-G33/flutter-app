import 'package:flutter/material.dart';
import 'views/home_view.dart';

void main() {
  runApp(const ArtLensApp());
}

class ArtLensApp extends StatelessWidget {
  const ArtLensApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtLens',
      theme: ThemeData(
        fontFamily: 'OpenSans', // Apply OpenSans globally
        primaryColor: Colors.white, // Primary color as white
        scaffoldBackgroundColor: Colors.white, // Ensures the background is white as well

        colorScheme: ColorScheme(
          primary: Colors.white, // White for primary
          onPrimary: Colors.black, // Black for contrast text on primary
          secondary: Color(0xFFA0522D), // Accent color #A0522D (brownish)
          onSecondary: Colors.white, // Contrast for secondary
          surface: Colors.white,
          onSurface: Colors.black, // Black contrast for surface
          error: Colors.red, // Error color
          onError: Colors.white, // Contrast for error
          brightness: Brightness.light, // Light theme
        ),

        // Updated TextTheme with OpenSans and consistent styling
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700), // Large titles
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),    // Large body text
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),   // Medium body text
        ),
      ),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
