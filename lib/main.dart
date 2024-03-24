import 'dart:html' as html;


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soltwin_se2702/Views/he104.dart';
import 'package:soltwin_se2702/Views/home.dart';
import 'package:soltwin_se2702/Views/se2702.dart';

void main() {
  runApp(MyApp());
  setupVisibilityChangeListener();
}

void setupVisibilityChangeListener() {
  html.document.addEventListener('visibilitychange', (_) {
    if (html.document.visibilityState == 'visible') {
      print('Page is visible');
      // Code to handle when the page becomes visible
    } else {
      print('Page is hidden');
      // Code to handle when the page becomes hidden
    }
  });
}

class MyApp extends StatelessWidget {

  final GoRouter _routers = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state){
          return const HomePage();
        }
      ),
      GoRoute(
        path: '/se2702',
        builder: (BuildContext context, GoRouterState state){
          return const SE2702();
        }
      ),
      GoRoute(
        path: '/he104',
        builder: (BuildContext context, GoRouterState state){
          return const HE104();
        }
      ),
    ]
  );

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SOLTWIN SE270-2',
      theme: ThemeData(
        // Define light theme settings (used if you switch to light theme manually)
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        // other light theme configurations
      ),
      darkTheme: ThemeData(
        // Define dark theme settings
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
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
          // other text style configurations
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueGrey[700], // Deep blue color for buttons
        ),
        // other dark theme configurations
      ),
      themeMode: ThemeMode.dark, // Force dark theme
      routerConfig: _routers,
      debugShowCheckedModeBanner: false,
    );
  }
}