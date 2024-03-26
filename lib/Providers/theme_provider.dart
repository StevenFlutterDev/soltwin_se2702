
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeMode themeMode = ThemeMode.dark;

  ThemeMode get themeData => themeMode;

  void toggleTheme() {
    if (themeMode == ThemeMode.dark) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
    notifyListeners(); // Notify widgets of theme change
  }
}

class MyThemes{
  static final darkTheme = ThemeData(
    // Define dark theme settings
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      color: Colors.grey[900], // A darker color for dark theme AppBar
    ),
    cardColor: const Color(0xFF1E1E1E),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 16
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
      ),
      bodySmall: TextStyle(color: Color(0xFFFFFFFF)),
      labelLarge: TextStyle(color: Color(0xFFE0E0E0)),
      labelMedium: TextStyle(color: Color(0xFFFFFFFF)),
      labelSmall: TextStyle(color: Color(0xFFFFFFFF)),
      // other text style configurations
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blueGrey[700], // Deep blue color for buttons
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blueGrey[700]),
        foregroundColor: MaterialStateProperty.all(Colors.white), // Set text color to white
      ),
    ),
    // other dark theme configurations
  );

  static final lightTheme = ThemeData(
    // Define light theme settings
    brightness: Brightness.light,
    primaryColor: Colors.blue[800], // Choose a lighter shade for the primary color
    appBarTheme: AppBarTheme(
      color: Colors.blue[800], // A darker shade for light theme AppBar
    ),
    cardColor: const Color(0xFFFFFFFF), // Typically, light themes use a white or very light color for cards
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Color(0xFF000000), // Use a darker color for text on a light background
          fontSize: 16
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF000000), // Use a darker color for text on a light background
        fontSize: 16,
      ),
      bodySmall: TextStyle(color: Color(0xFF000000)), // Use a darker color for smaller text
      labelLarge: TextStyle(color: Color(0xFF000000)),
      labelMedium: TextStyle(color: Color(0xFF000000)),
      labelSmall: TextStyle(color: Color(0xFF000000)),
      // other text style configurations
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue[500], // A lighter shade of blue for buttons in the light theme
      textTheme: ButtonTextTheme.normal
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blue[500]),
        foregroundColor: MaterialStateProperty.all(Colors.black),
      ),
    ),
    // Override the TextButton theme to ensure high contrast in the AppBar
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.white), // Use a light color for text
      ),
    ),
    // other light theme configurations
  );

}
